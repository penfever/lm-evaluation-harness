#!/bin/bash -x

#SBATCH --output=run_eleuther_expt-%j.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --account=pr_95_tandon_priority
#SBATCH --time=47:59:00
#SBATCH --mem=128GB
#SBATCH --gres=gpu:1
#SBATCH --constraint="a100|h100"
#SBATCH --job-name=run_eleuther_expt
#SBATCH --mail-type=BEGIN,END
#SBATCH --mail-user=bf996@nyu.edu

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK;
export MASTER_PORT=$(shuf -i 10000-65500 -n 1);
export MASTER_ADDR="$(hostname -s).hpc.nyu.edu";

#python /scratch/bf996/lm-evaluation-harness/scripts/check_if_results_exist.py nyu-dice-lab/lm-eval-results-%%MODEL_NAME%% && 

srun \
    /bin/bash /scratch/bf996/lm-evaluation-harness/scripts/eleuther_env.bash \
    /bin/bash -c \
    'lm_eval --model hf --output_path results/%%MODEL_NAME_NOSLASH%% --model_args pretrained=%%MODEL_NAME%%,dtype=bfloat16 --tasks leaderboard,safety,bbq,wmdp --use_cache /scratch/bf996/lm-evaluation-harness-%%MODEL_NAME_NOSLASH%% --cache_requests true --log_samples --device cuda:0 --batch_size auto --hf_hub_log_args hub_results_org=nyu-dice-lab,hub_repo_name=lm-eval-results-%%MODEL_NAME_NOSLASH%%,push_results_to_hub=True,push_samples_to_hub=True,public_repo=False;'