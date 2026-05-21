#/bin/bash
~/Documents/llama-mtp/llama.cpp/build/bin/llama-cli \
    -hf unsloth/Qwen3.6-27B-MTP-GGUF:Q6_K \
    --temp 1.0 \
    --top-p 0.95 \
    --top-k 20 \
    --presence-penalty 1.5 \
    --min-p 0.00 \
    --spec-type mtp --spec-draft-n-max 2
