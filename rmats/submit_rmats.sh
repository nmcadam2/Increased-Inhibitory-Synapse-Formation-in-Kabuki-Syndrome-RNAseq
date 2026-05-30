#!/bin/bash
#$ -q long
#$ -pe smp 8
#$ -N rmats_E1KS1_
#$ -o logs/rmats_E1KS1.out
#$ -e logs/rmats_E1KS1.err

wd="$(pwd)"
source ~/.bashrc

#Directory checks
mkdir -p "${wd}/output" "${wd}/logs" "${wd}/temp"
echo "[$(date)]: ensured output/, logs/, and temp/ exist"

#Define inputs
b1="${wd}/input/bam1.txt"
b2="${wd}/input/bam2.txt"
gtf="/groups/cpatzke/references/annotations/RefSeqGRCm39_genomic.gtf"
outDir="${wd}/output"
temp="${wd}/temp"

#Variable check
echo "[$(date)]: gtf=${gtf}"
echo "[$(date)]: b1=${b1}"
echo "[$(date)]: b2=${b2}"
echo "[$(date)]: Write results to:${outDir}"

echo "[$(date)]: Beginning rmats run with default cstat value..."
echo ""

#Clear temp - If temp contains the files from a previous run of rmats then it will refuse to run
rm "${temp}"/*

#Print what is being run
echo "[$(date)]: ${wd}/rmats-turbo/run_rmats --gtf ${gtf} --b1 ${b1} --b2 ${b2} \
  -t paired \
  --readLength 101 \
  --variable-read-length \
  --nthread 8 \
  --task both \
  --od ${outDir}/E1KS1 \
  --tmp ${temp}"

printf "\n\n"

#Run rmats
"${wd}"/rmats-turbo/run_rmats --gtf "${gtf}" --b1 "${b1}" --b2 "${b2}" \
  -t paired \
  --readLength 101 \
  --variable-read-length \
  --nthread 8 \
  --task both \
  --od "${outDir}/E1KS1" \
  --tmp "${temp}"


echo ""
echo "[$(date)]: rmats run complete!"
