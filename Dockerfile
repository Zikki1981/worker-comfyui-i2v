# ComfyUI I2V Worker for RunPod Serverless
# Optimized for Wan2.2 I2V with Network Volume
FROM runpod/worker-comfyui:5.8.5-base

# ============================================
# CUSTOM NODES ONLY
# Models are loaded from Network Volume
# ============================================
RUN comfy node install \
    comfyui-wanvideowrapper \
    comfyui-videohelpersuite \
    comfyui-kjnodes \
    rgthree-comfy \
    comfyui-impact-pack \
    comfyui-frame-interpolation \
    comfyui-florence2

# ============================================
# VOLUME SETUP SCRIPT
# Creates symlinks from Network Volume to ComfyUI
# ============================================
COPY scripts/setup_volume.sh /setup_volume.sh
RUN chmod +x /setup_volume.sh

# ============================================
# HANDLER CONFIG
# ============================================
ENV COMFY_POLLING_INTERVAL=500
ENV COMFY_POLLING_MAX_RETRIES=300

# Run volume setup before starting
ENTRYPOINT ["/bin/bash", "-c", "/setup_volume.sh && exec /start.sh"]
