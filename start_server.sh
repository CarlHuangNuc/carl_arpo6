#!/bin/bash

model="/mnt/nfsdata/carl/ARPO_UITARS1.5_7B"
model_name=ui-tars
num_images=16

port=9000

# Function to clean up processes on exit
cleanup() {
    echo "Stopping all processes..."
    pkill -P $$  # Kill all child processes of this script
    exit 0
}

# Trap SIGINT (Ctrl+C) and SIGTERM to run cleanup function
trap cleanup SIGINT SIGTERM

# Start processes
for i in {0..7}; do
    CUDA_VISIBLE_DEVICES=$i python -m vllm.entrypoints.openai.api_server \
        --served-model-name $model_name \
        --model $model \
        --limit-mm-per-prompt image=$num_images \
        --tp=1 \
        --max-num-seqs 8 \
        --max-model-len 48000 \
        --swap-space 50 \
        --gpu-memory-utilization 0.9 \
        --port $((9000 + i)) &
done

# Wait to keep the script running
wait
