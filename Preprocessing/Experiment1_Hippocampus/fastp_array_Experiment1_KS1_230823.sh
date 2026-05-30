#!/bin/bash
#$ -q long
#$ -pe smp 8
#$ -t 1-6
#$ -N Experiment1_KS1_fastp_230823
#$ -o logs/fastp_trimming_Experiment1_KS1_230823_$TASK_ID.out
#$ -e logs/fastp_trimming_Experiment1_KS1_230823_$TASK_ID.err

wd=$(pwd)
set -euo pipefail
trap 'echo "[$(date)] ERROR at line ${LINENO}: ${BASH_COMMAND}" >&2' ERR

#Directory checks
mkdir -p "${wd}/output" "${wd}/logs" "${wd}/output/trimmed/230823"
echo "[$(date)]: ensured output/, logs/, output/trimmed/230823 exist"

#activate conda env
source /users/nmcadam2/.bashrc
conda activate fastp

#Input discovery
mapfile -t files < <(ls -1 "${wd}"/data/230823/*_R1_*fastq.gz | sort)

idx=$((SGE_TASK_ID - 1))
if [[ $idx -lt 0 || $idx -ge ${#files[@]} ]]; then
  echo "ERROR: SGE_TASK_ID=${SGE_TASK_ID} out of range (n_files=${#files[@]})." >&2
  exit 2
fi

#Grab reads from array
R1="${files[$idx]}"
R2="${R1/_R1_/_R2_}"
sample="$(basename "${R1/_R1_*/}")"
minLength=60


if [[ ! -f "$R2" ]]; then
  echo "ERROR: Missing R2 mate for R1=$R1. Expected R2=$R2" >&2
  exit 3
fi

#Variable check
echo "[$(date)]: TASK=${SGE_TASK_ID} sample=${sample}"
echo "[$(date)]: R1=${R1}"
echo "[$(date)]: R2=${R2}"
echo "[$(date)]: Output Directory=${wd}/output/trimmed/230823"

#run fastp
echo -e "\n[$(date)]: Beginning fastp trimming of 230823 sample:"${sample}"...\n"

set -x # ensures the exact version of the command is printed to the log before running

fastp \
  -i "$R1" \
  -I "$R2" \
  -o "${wd}"/output/trimmed/230823/"$(basename "${R1/fastq.gz/trimmed.fastq.gz}")" \
  -O "${wd}"/output/trimmed/230823/"$(basename "${R2/fastq.gz/trimmed.fastq.gz}")" \
  --detect_adapter_for_pe \
  --length_required "${minLength}" \
  --trim_poly_g \
  --cut_mean_quality 30 \
  --thread 8 \
  --html "${wd}"/output/trimmed/230823/"${sample}".fastp.html \
  --json "${wd}"/output/trimmed/230823/"${sample}".fastp.json

set +x

echo -e "\n[$(date)]: Finished trimming!"
conda deactivate
