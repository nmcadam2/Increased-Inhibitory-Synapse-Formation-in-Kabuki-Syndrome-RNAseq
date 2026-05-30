#!/bin/bash
#$ -q long
#$ -pe smp 2
#$ -t 1-5
#$ -N sashimi_exp1_rmatsrun3
#$ -o logs/sashimi_res_exp1_rmatsrun3_$TASK_ID.out
#$ -e logs/sashimi_res_exp1_rmatsrun3_$TASK_ID.err

wd="$(pwd)"
source ~/.bashrc
conda activate sashimi_env

#Directory checks
mkdir -p "${wd}/output" "${wd}/logs" "${wd}/temp"
echo "[$(date)]: ensured output/, logs/, and temp/ exist"

#Input discovery
mapfile -t files < <(ls -1 "${wd}"/input/jcec_sashimi/*sashimi.txt | sort)

idx=$((SGE_TASK_ID - 1))
if [[ $idx -lt 0 || $idx -ge ${#files[@]} ]]; then
  echo "ERROR: SGE_TASK_ID=${SGE_TASK_ID} out of range (n_files=${#files[@]})." >&2
  exit 2
fi

#Grab file
event_file="${files[$idx]}"
base="$(basename "${event_file}")"
event_type="${base%%.MATS.JCEC_sashimi.txt}"

b1="${wd}"/input/bam1.txt
b2="${wd}"/input/bam2.txt
groups="${wd}"/input/grouping.gf
outdir="${wd}"/output/"${event_type}"
mkdir -p "${outdir}"
echo "[$(date)]: made output directory for ${event_type} at ${outdir}"

#Variable check
echo "[$(date)]: TASK=${SGE_TASK_ID} event file=${event_file}"
echo "[$(date)]: bam1=${b1}"
echo "[$(date)]: bam2=${b2}"
echo "[$(date)]: grouping info=${groups}"
echo "[$(date)]: outdir =${outdir}"
echo ""

#Sashimi - modified the misopy sashimi_plot.py script to remove glob.escape (this undoes the commit 1eeb738 as described in issue #152 on the rmats2sashimiplot github.)
#/users/user/.conda/envs/sashimi_env/lib/python2.7/site-packages/rmats2sashimiplot-3.0.0-py2.7.egg/MISO/misopy/sashimi_plot/sashimi_plot.py line 139
echo "[$(date)]: beginning rmats2sashimi run..."
#echo "[$(date)]: rmats2sashimiplot --b1 "${b1}" --b2 "${b2}" \
#  --event-type "${event_type}" \
#  --l1 Mutants \
#  --l2 Wildtype \
#  -e "${event_file}" \
#  -o "${outdir}" \
#  --group-info "${groups}""

rmats2sashimiplot --b1 "${b1}" --b2 "${b2}" \
  --event-type "${event_type}" \
  --l1 Mutants \
  --l2 Wildtype \
  -e "${event_file}" \
  -o "${outdir}" \
  --intron_s 5 \
  --group-info "${groups}"

echo "[$(date)]: finished ${event_type} plot gen!"
conda deactivate
