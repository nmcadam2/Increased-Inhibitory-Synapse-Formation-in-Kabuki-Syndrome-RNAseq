#!/bin/bash
#$ -q long
#$ -pe smp 8
#$ -t 1-6
#$ -N Experiment2_KS1_hisat
#$ -o logs/hisat_mapping_Experiment2_KS1_$TASK_ID.out
#$ -e logs/hisat_mapping_Experiment2_KS1_$TASK_ID.err

wd="$(pwd)"
set -euo pipefail
trap 'echo "[$(date)] ERROR at line ${LINENO}: ${BASH_COMMAND}" >&2' ERR

# Directory checks
mkdir -p "${wd}/output" "${wd}/logs" "${wd}/output/mapped/summary"
echo "[$(date)]: ensured output/, logs/, output/mapped/summary/ exist"

# module load
module load bio/2.0

#Input discovery
mapfile -t files < <(ls -1 "${wd}"/output/trimmed/*_R1_*.trimmed.fastq.gz | sort)

idx=$((SGE_TASK_ID - 1))
if [[ $idx -lt 0 || $idx -ge ${#files[@]} ]]; then
  echo "ERROR: SGE_TASK_ID=${SGE_TASK_ID} out of range (n_files=${#files[@]})." >&2
  exit 2
fi

#Grab reads from array
R1="${files[$idx]}"
R2="${R1/_R1_/_R2_}"

if [[ ! -f "$R2" ]]; then
  echo "ERROR: Missing R2 mate for R1=$R1. Expected R2=$R2" >&2
  exit 3
fi

#Derive sample name
base="$(basename "$R1")"
sample="${base%%_R1_*}"

reference="/groups/cpatzke/references/indices/RefSeq_GRCm39_tran"

bam_out="${wd}"/output/mapped/"${sample}".bam
summary_out="${wd}"/output/mapped/summary/"${sample}".hisat2.summary.txt
metrics_out="${wd}"/output/mapped/summary/"${sample}".hisat2.metrics.txt

#Variable check
echo "[$(date)]: TASK=${SGE_TASK_ID} sample=${sample}"
echo "[$(date)]: R1=${R1}"
echo "[$(date)]: R2=${R2}"
echo "[$(date)]: BAM=${bam_out}"

#Align + sort
echo -e "\n[$(date)]: Beginning alignment of "${sample}"...\n"

set -x # ensures the exact version of the command is printed to the log before running

hisat2 -p 8 -x "${reference}" -1 "${R1}" -2 "${R2}" \
  --new-summary --summary-file "${summary_out}" --met-file "${metrics_out}" \
  | samtools sort -@ 8 -o "${bam_out}" -

samtools index "${bam_out}"

set +x

echo -e "\n[$(date)]: Alignment complete!"
module unload bio/2.0
