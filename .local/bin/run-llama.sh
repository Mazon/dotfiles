#!/bin/bash
#--ctx-size 131072 \
#~/Documents/llama-mtp/llama.cpp/build/bin/llama-server \
/usr/local/bin/llama-server \
  --model /home/mazon/llama/models/Qwen3.6-27B-Q6_K-MTP.gguf \
  --n-gpu-layers -1 \
  --ctx-size 131072 \
  --parallel 1 \
  --batch-size 512 \
  --ubatch-size 256 \
  --no-mmap \
  --flash-attn on \
  --jinja \
  --cache-type-k q8_0 \
  --cache-type-v q8_0 \
  --threads $(nproc) \
  --spec-type draft-mtp \
  --spec-draft-p-min 0.75 \
  --spec-draft-n-max 2 \
  -ctkd q8_0 -ctvd q8_0 \
  --chat-template-kwargs '{"preserve_thinking": true}' \
  --temp 0.6 --top-p 0.95 --top-k 20 --min-p 0.00 --presence-penalty 0.0 --repeat-penalty 1.0 \
  --ctx-checkpoints 4 \
  --kv-unified \
  --host 0.0.0.0 \
  --port 8080 
