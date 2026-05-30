#!/bin/bash
#$ -q long
#$ -pe smp 8
#$ -t 1-6
#$ -N Experiment1_KS1_hisat
#$ -o logs/hisat_Ex1_KS1_final_$TASK_ID.out
#$ -e logs/hisat_Ex1_KS1_final_$TASK_ID.err

wd="$(pwd)"
set -euo pipefail
trap 'echo "[$(date)] ERROR at line ${LINENO}: ${BASH_COMMAND}" >&2' ERR

# Directory checks
mkdir -p "${wd}/output" "${wd}/logs" "${wd}/output/mapped/summary"
echo "[$(date)]: ensured output/, logs/, output/mapped/summary/ exist"

# module load
module load bio/2.0

#Input discovery
mapfile -t files < <(ls -1 "${wd}"/output/trimmed/230823/*_R1_*.trimmed.fastq.gz | sort)

idx=$((SGE_TASK_ID - 1))
if [[ $idx -lt 0 || $idx -ge ${#files[@]} ]]; then
  echo "ERROR: SGE_TASK_ID=${SGE_TASK_ID} out of range (n_files=${#files[@]})." >&2
  exit 2
fi

#Grab reads from array
run1R1="${files[$idx]}"
run1R2="${run1R1/_R1_/_R2_}"

run2R1="${run1R1/230823/230830}"
run2R2="${run1R2/230823/230830}"

if [[ ! -f "$run1R2" ]]; then
  echo "ERROR: Missing run1 R2 mate for run1 R1=$run1R1. Expected R2=$run1R2" >&2
  exit 3
fi

if [[ ! -f "$run2R1" ]]; then
  echo "ERROR: Missing run2 R1. Expected $run2R1" >&2
  exit 4
fi

if [[ ! -f "$run2R2" ]]; then
  echo "ERROR: Missing run2 R2. Expected $run2R2" >&2
  exit 5
fi


#Derive sample name
base="$(basename "$run1R1")"
sample="${base%%_R1_*}"

reference="/groups/cpatzke/references/indices/RefSeq_GRCm39_tran"

bam_out="${wd}"/output/mapped/"${sample}".bam
summary_out="${wd}"/output/mapped/summary/"${sample}".hisat2.summary.txt
metrics_out="${wd}"/output/mapped/summary/"${sample}".hisat2.metrics.txt

#Variable check
echo "[$(date)]: TASK=${SGE_TASK_ID} sample=${sample}"
echo "[$(date)]: R1s=${run1R1},${run2R1}"
echo "[$(date)]: R2s=${run1R2},${run2R2}"
echo "[$(date)]: BAM=${bam_out}"

#Align + sort
echo -e "\n[$(date)]: Beginning alignment of "${sample}"...\n"

set -x # ensures the exact version of the command is printed to the log before running

hisat2 -p 8 -x "${reference}" \
  -1 "${run1R1}","${run2R1}" \
  -2 "${run1R2}","${run2R2}" \
  --new-summary --summary-file "${summary_out}" --met-file "${metrics_out}" \
  | samtools sort -@ 8 -o "${bam_out}" -

samtools index "${bam_out}"

set +x

echo -e "\n[$(date)]: Alignment complete!"
module unload bio/2.0
