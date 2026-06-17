#!/bin/bash
# Stability test variant: MTP speculative decoding DISABLED.
# Use this to confirm MTP is the crash trigger (Xid 8 / launch timed out).
# If crashes stop with this script, MTP is confirmed as the cause.
/usr/local/bin/llama-server \
  --model /home/mazon/llama/models/Qwen3.6-27B-Q6_K-MTP.gguf \
  --n-gpu-layers -1 \
  --ctx-size 163840 \
  --parallel 1 \
  --batch-size 512 \
  --ubatch-size 512 \
  --cache-ram 28672 \
  --no-mmap \
  --flash-attn on \
  --jinja \
  --cache-type-k q8_0 \
  --cache-type-v q8_0 \
  --threads $(nproc) \
  --reasoning on \
  --temp 0.6 --top-p 0.95 --top-k 20 --min-p 0.00 --presence-penalty 0.0 --repeat-penalty 1.0 \
  --no-mmproj \
  --ctx-checkpoints 4 \
  --checkpoint-every-n-tokens 2048 \
  --kv-unified \
  --host 0.0.0.0 \
  --port 11434
