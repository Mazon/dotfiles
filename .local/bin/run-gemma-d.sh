#!/bin/bash
# VRAM-optimized for 32 GB GPU: ~22 GB model + ~8 GB for live KV.
# Checkpoints live in system RAM (--cache-ram), NOT VRAM.
#~/Documents/llama-mtp/llama.cpp/build/bin/llama-server \
# not sure exaktly what this does
#export GGML_CUDA_GRAPH_OPT=1
#/usr/local/bin/llama-server \
/home/mazon/Documents/llama.cpp/build/bin/llama-server \
  --model /home/mazon/llama/models/diffusiongemma-26B-A4B-it-Q6_K.gguf \
  -ngl 999 \
  --ctx-size 131072 \
  --parallel 1 \
  --batch-size 1024 \
  --ubatch-size 1024 \
  --cache-ram 28672 \
  --no-mmap \
  --flash-attn on \
  --cache-type-k q8_0 \
  --cache-type-v q8_0 \
  --threads $(nproc) \
  -ctkd q8_0 -ctvd q8_0 \
  --reasoning on \
  --temp 0.6 --top-p 0.95 --top-k 20 --min-p 0.00 --presence-penalty 0.0 --repeat-penalty 1.0 \
  --kv-unified \
  --diffusion-visual \
  --host 0.0.0.0 \
  --port 11434

