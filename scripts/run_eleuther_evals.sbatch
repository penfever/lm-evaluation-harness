#!/bin/bash -x

#SBATCH --output=run_eleuther_evals-%j.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --account=pr_95_tandon_priority
#SBATCH --time=99:59:00
#SBATCH --mem=16GB
#SBATCH --job-name=run_eleuther_evals
#SBATCH --mail-type=BEGIN,END
#SBATCH --mail-user=bf996@nyu.edu

srun \
    cd /scratch/bf996/lm-evaluation-harness/scripts; \
    ls; \
    cd scripts; \
    ls; \
    source run-cmd.bash; \
    echo "Eleuther experiments done."; \
