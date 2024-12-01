#!/bin/bash
set -e

##############################
run_experiment_slurm(){

  # $1 = model name
  model_name="$1"

  echo "run_experiment: model_name: ${model_name}"

  # maximum number of attempts at creating slurm instance
  MAX_TRIES=2

  COUNT=1
  while [ $COUNT -le $MAX_TRIES ]; do

    # TODO: srun or sbatch, save return code
    job1=$(sbatch /scratch/bf996/lm-evaluation-harness/scripts/eleuther_batch_mod.sbatch | awk '{print $4}')

    echo "Executing job ${model_name}"
    echo "Job id is ${job1}"

    while true; do
    # Check if the output of the squeue command is empty
    if [[ -z $(squeue -j "$job1") ]]; then
        echo "Job $job1 has finished."
        # Get the exit code
        sacct_output=$(sacct -j "$job1" --format=JobID,ExitCode)
        # Extract only the exit code part
        declare -i INSTANCE_RETURN_CODE
        INSTANCE_RETURN_CODE=$(echo "$sacct_output" | grep "^$job1" | awk '{print $2}' | cut -d: -f1)
        break
    else
        sleep 60
    fi
    done

    if [[ $INSTANCE_RETURN_CODE -ne 0 ]]; then
      # failed to create instance
      let COUNT=COUNT+1
      echo "failed to create instance during attempt ${COUNT}... (exit code: ${INSTANCE_RETURN_CODE})"
      if [[ $COUNT -ge $(( $MAX_TRIES + 1 )) ]]; then
        echo "too many create-instance attempts. giving up."
        exit 1
      fi
      echo "trying again in 30 seconds..."
      sleep 30
    else
      # success!
      break
    fi
  done
  echo "successfully created instance: ${instance_name}"
}

##############################
# begin: EXPERIMENT PARAMETERS

# this defines MODELS
source eleuther_modelset.sh

# make a log directory
mkdir -p ${PWD}/logs
LOG_DIR=${PWD}/logs

# maximum number of experiments (background processes) that can be running
MAX_PROCESSES=10

for i in ${!MODELS[@]};
do
    model=${MODELS[$i]}
    model_noslash=$(echo $model | sed 's/\//\-/g')
    sed -e "s#%%MODEL_NAME%%#${model}#g" \
    -e "s#%%MODEL_NAME_NOSLASH%%#${model_noslash}#g" \
    /scratch/bf996/lm-evaluation-harness/scripts/eleuther_batch.sbatch > /scratch/bf996/lm-evaluation-harness/scripts/eleuther_batch_mod.sbatch
    sleep 2

    run_experiment_slurm "${model}" >> ${LOG_DIR}/log_${i}_$(date +"%m%d%y_%H%M%S").txt 2>&1 &

    # if we have started MAX_PROCESSES experiments, wait for them to finish
    while true; do
      # Check if the output of the squeue command is empty
      cur_job_count_squeue=$(squeue -u $(whoami) | tail -n +2 | wc -l)
      if [ "$cur_job_count_squeue" -ge "$MAX_PROCESSES" ]; then
          sleep 120
      else
          break
      fi
    done
done
