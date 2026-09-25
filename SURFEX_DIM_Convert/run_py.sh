#!/bin/bash
###SBATCH -N 2
#SBATCH -t 01:00:00
#SBATCH -n 8  ##ntasks
####SBATCH --mem=256000
#SBATCH --job-name=DIMCONVERT
###SBATCH --output=dimconvert.%j.out
###SBATCH --error=dimconvert.%j.error
#SBATCH -e slurm_error.txt
#SBATCH -o slurm_output.txt
#SBATCH -A rossby


current_date_time="`date`";
echo The run starts from $current_date_time

rm -f dimconvert*
#set -exu 

source ~sm_fuxwa/anaconda2/bin/activate 
python main.py 

current_date_time="`date`";
echo The run ends at $current_date_time

#mv dimconvert* /nobackup/rossby27/users/sm_fuxwa/SURFEX_OUT/BRIGHT/Stockholm/

exit 0
