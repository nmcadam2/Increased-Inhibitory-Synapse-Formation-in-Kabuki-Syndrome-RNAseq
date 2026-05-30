#!/bin/bash
#$ -q long
#$ -pe smp 8
#$ -N Experiment1_KS1_featureCounts
#$ -o logs/featureCounts_counting_Experiment1_KS1.out
#$ -e logs/featureCounts_counting_Experiment1_KS1.err

wd=$(pwd)
set -euo pipefail
trap 'echo "[$(date)] ERROR at line ${LINENO}: ${BASH_COMMAND}" >&2' ERR

#Directory checks
mkdir -p "${wd}/output" "${wd}/logs" "${wd}/output/counts"
echo "[$(date)]: ensured output/, logs/, output/counts/ exist"

#Activate conda env
source /users/nmcadam2/.bashrc
conda activate featurecount

#Input discovery
mapfile -t files < <(ls -1 "${wd}"/output/mapped/*.bam | sort)

#Define variables
reference="/groups/cpatzke/references/annotations/RefSeqGRCm39_genomic.gtf"

#Variable check
printf "[%s]: Input Bams:\n" "$(date)"
printf "  %s\n" "${files[@]}"
echo "[$(date)]: Reference file = ${reference}"
echo "[$(date)]: Output Directory=${wd}/output/counts/"

#Run feature counts
echo -e "\n[$(date)]: Counting by exon, aggregated to counts.\n"

set -x # ensures the exact version of the command is printed to the log before running

featureCounts \
  -T 8 \
  -a "${reference}" \
  -o "${wd}/output/counts/counts_kabukiE1_fixed.txt" \
  -t exon \
  -g gene_id \
  -p \
  -C \
  -M \
  --fraction \
  "${files[@]}"


set +x

echo -e "\n[$(date)]: Finished counting!"
conda deactivate
