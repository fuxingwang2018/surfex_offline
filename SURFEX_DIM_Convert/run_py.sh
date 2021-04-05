#!/bin/bash
#SBATCH -N 1
#SBATCH -t 6:00:00
####SBATCH -n 1  ##ntasks
####SBATCH --mem=256000
#SBATCH -J DIM_CONVERT
#SBATCH -e slurm_error.txt
#SBATCH -o slurm_output.txt

python surfex_dim_convert.py 
exit 0
