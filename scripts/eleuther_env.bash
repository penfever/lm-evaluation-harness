#!/bin/bash

args=''
for i in "$@"; do 
  i="${i//\\/\\\\}"
  args="$args \"${i//\"/\\\"}\""
done
echo $args
ls
if [ "$args" == "" ]; then args="/bin/bash"; fi

if [[ "$(hostname -s)" =~ ^g[r,v,a] ]]; then nv="--nv"; fi

#/scratch/work/public/singularity/cuda12.1.1-cudnn8.9.0-devel-ubuntu22.04.2.sif

singularity \
  exec $nv \
  --overlay /scratch/bf996/singularity_containers/eleuther-ai-harness.ext3:ro \
  /scratch/work/public/singularity/cuda11.7.99-cudnn8.5-devel-ubuntu22.04.2.sif \
  /bin/bash -c "
 source /ext3/env.sh && \
 conda activate eleuther && \
 cd /scratch/bf996/lm-evaluation-harness; \
 $args
"