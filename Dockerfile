# ComfyUI I2V Worker for RunPod Serverless
# Optimized for Wan2.2 I2V with custom LoRAs
FROM runpod/worker-comfyui:3.6.0-base

# ============================================
# CUSTOM NODES
# ============================================
RUN comfy-node-install \
    comfyui-wanvideowrapper \
    comfyui-videohelpersuite \
    comfyui-kjnodes \
    rgthree-comfy \
    comfyui-impact-pack \
    comfyui-frame-interpolation \
    comfyui-florence2

# ============================================
# TEXT ENCODERS
# ============================================
RUN comfy model download \
    --url "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp16.safetensors" \
    --relative-path models/text_encoders \
    --filename umt5_xxl_fp16.safetensors

# ============================================
# VAE
# ============================================
RUN comfy model download \
    --url "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors" \
    --relative-path models/vae \
    --filename wan_2.1_vae.safetensors

RUN comfy model download \
    --url "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_repackaged/resolve/main/split_files/vae/wan2.2_vae.safetensors" \
    --relative-path models/vae \
    --filename wan2.2_vae.safetensors

# ============================================
# DIFFUSION MODELS - Wan2.2 I2V 14B
# ============================================
RUN mkdir -p /comfyui/models/diffusion_models/Wan2.2

RUN comfy model download \
    --url "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp16.safetensors" \
    --relative-path models/diffusion_models/Wan2.2 \
    --filename wan2.2_i2v_high_noise_14B_fp16.safetensors

RUN comfy model download \
    --url "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp16.safetensors" \
    --relative-path models/diffusion_models/Wan2.2 \
    --filename wan2.2_i2v_low_noise_14B_fp16.safetensors

# ============================================
# BASE LORAS - SVI Pro & LightX2V
# ============================================
# SVI Pro LoRAs (high quality)
RUN comfy model download \
    --url "https://huggingface.co/svjack/Wan2.2-I2V-14B-SVI-LoRA/resolve/main/SVI_Wan2.2-I2V-A14B_high_noise_lora_v2.0_pro.safetensors" \
    --relative-path models/loras \
    --filename SVI_Wan2.2-I2V-A14B_high_noise_lora_v2.0_pro.safetensors

RUN comfy model download \
    --url "https://huggingface.co/svjack/Wan2.2-I2V-14B-SVI-LoRA/resolve/main/SVI_Wan2.2-I2V-A14B_low_noise_lora_v2.0_pro.safetensors" \
    --relative-path models/loras \
    --filename SVI_Wan2.2-I2V-A14B_low_noise_lora_v2.0_pro.safetensors

# LightX2V acceleration LoRAs (4-step distillation)
RUN comfy model download \
    --url "https://huggingface.co/Lightricks/LTX-Video-Distilled/resolve/main/lightx2v_I2V_14B_480p_cfg_step_distill_rank256_bf16.safetensors" \
    --relative-path models/loras \
    --filename lightx2v_I2V_14B_480p_cfg_step_distill_rank256_bf16.safetensors

# ============================================
# CUSTOM I2V LORAS (from CivitAI)
# Add your LoRAs here with CivitAI download URLs
# Format:
# RUN curl -L -o /comfyui/models/loras/FILENAME.safetensors \
#     "https://civitai.com/api/download/models/MODEL_VERSION_ID?token=YOUR_CIVITAI_TOKEN"
# ============================================

# Placeholder - uncomment and add your LoRAs:
# RUN curl -L -o /comfyui/models/loras/handjob_i2v.safetensors \
#     "https://civitai.com/api/download/models/XXXXXX?token=ddc6509170e2463e5dd76ea74008fa82"

# ============================================
# WORKFLOW
# ============================================
COPY workflows/ /comfyui/user/default/workflows/

# ============================================
# HANDLER CONFIG
# ============================================
ENV COMFY_POLLING_INTERVAL=500
ENV COMFY_POLLING_MAX_RETRIES=300
