#!/bin/bash
# Script to populate RunPod Network Volume with required models
# Run this on any machine with AWS CLI configured

VOLUME_PATH="/runpod-volume"

# Set these environment variables before running:
# export CIVITAI_TOKEN="your_civitai_token"
# export HF_TOKEN="your_huggingface_token"
CIVITAI_TOKEN="${CIVITAI_TOKEN:-}"
HF_TOKEN="${HF_TOKEN:-}"

echo "=========================================="
echo "Populating Network Volume with I2V Models"
echo "=========================================="

if [ -z "$HF_TOKEN" ]; then
    echo "WARNING: HF_TOKEN not set. Some downloads may fail."
fi

# Create directory structure
mkdir -p "$VOLUME_PATH/models/diffusion_models/Wan2.2"
mkdir -p "$VOLUME_PATH/models/text_encoders"
mkdir -p "$VOLUME_PATH/models/vae"
mkdir -p "$VOLUME_PATH/models/loras"
mkdir -p "$VOLUME_PATH/models/unet"
mkdir -p "$VOLUME_PATH/workflows"

cd "$VOLUME_PATH"

# Helper function for downloads
download_hf() {
    local url="$1"
    local dest="$2"
    if [ ! -f "$dest" ]; then
        echo "Downloading $(basename $dest)..."
        curl -L -o "$dest" "$url" --header "Authorization: Bearer $HF_TOKEN"
    else
        echo "$(basename $dest) already exists"
    fi
}

# ============================================
# DIFFUSION MODELS - Wan2.2 I2V 14B (~28GB total)
# ============================================
echo ""
echo "=== Downloading Wan2.2 I2V Diffusion Models ==="

download_hf \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp16.safetensors" \
    "models/diffusion_models/Wan2.2/wan2.2_i2v_high_noise_14B_fp16.safetensors"

download_hf \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp16.safetensors" \
    "models/diffusion_models/Wan2.2/wan2.2_i2v_low_noise_14B_fp16.safetensors"

# ============================================
# TEXT ENCODERS (~10GB)
# ============================================
echo ""
echo "=== Downloading Text Encoders ==="

download_hf \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp16.safetensors" \
    "models/text_encoders/umt5_xxl_fp16.safetensors"

# ============================================
# VAE
# ============================================
echo ""
echo "=== Downloading VAE Models ==="

download_hf \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors" \
    "models/vae/wan_2.1_vae.safetensors"

download_hf \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_repackaged/resolve/main/split_files/vae/wan2.2_vae.safetensors" \
    "models/vae/wan2.2_vae.safetensors"

# ============================================
# BASE LORAS
# ============================================
echo ""
echo "=== Downloading Base LoRAs ==="

download_hf \
    "https://huggingface.co/svjack/Wan2.2-I2V-14B-SVI-LoRA/resolve/main/SVI_Wan2.2-I2V-A14B_high_noise_lora_v2.0_pro.safetensors" \
    "models/loras/SVI_Wan2.2-I2V-A14B_high_noise_lora_v2.0_pro.safetensors"

download_hf \
    "https://huggingface.co/svjack/Wan2.2-I2V-14B-SVI-LoRA/resolve/main/SVI_Wan2.2-I2V-A14B_low_noise_lora_v2.0_pro.safetensors" \
    "models/loras/SVI_Wan2.2-I2V-A14B_low_noise_lora_v2.0_pro.safetensors"

download_hf \
    "https://huggingface.co/Lightricks/LTX-Video-Distilled/resolve/main/lightx2v_I2V_14B_480p_cfg_step_distill_rank256_bf16.safetensors" \
    "models/loras/lightx2v_I2V_14B_480p_cfg_step_distill_rank256_bf16.safetensors"

download_hf \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors" \
    "models/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors"

download_hf \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors" \
    "models/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors"

# ============================================
# SUMMARY
# ============================================
echo ""
echo "=========================================="
echo "Base Model Download Complete!"
echo "=========================================="
echo ""
echo "Disk usage:"
du -sh "$VOLUME_PATH/models"/* 2>/dev/null || echo "No models yet"
echo ""
echo "Total:"
du -sh "$VOLUME_PATH" 2>/dev/null
