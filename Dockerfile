# ComfyUI I2V Worker for RunPod Serverless
# Optimized for Wan2.2 I2V with Network Volume
FROM runpod/worker-comfyui:5.8.5-base

# ============================================
# CUSTOM NODES ONLY
# Models are loaded from Network Volume
# ============================================
# Core workflow nodes (from registry)
RUN comfy node install \
    comfyui-videohelpersuite \
    comfyui-kjnodes \
    rgthree-comfy \
    comfyui-impact-pack \
    comfyui-frame-interpolation \
    comfyui-florence2 \
    comfyui-easy-use \
    comfymath \
    comfyui-custom-scripts \
    comfyui-mxtoolkit \
    comfyui-tinyterranodes

# WanVideoWrapper - install from GitHub for latest version with WanVideoApplyNAG
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git && \
    cd ComfyUI-WanVideoWrapper && pip install -r requirements.txt || true

# FramePackWrapper needs git clone (not in registry)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-FramePackWrapper_Plus.git && \
    cd ComfyUI-FramePackWrapper_Plus && pip install -r requirements.txt || true

# Ergouzi nodes (for EG_WXZ_QH) - create web/extensions folder first to fix import error
RUN mkdir -p /comfyui/web/extensions/EG_GN_NODES && \
    cd /comfyui/custom_nodes && \
    git clone https://github.com/11dogzi/Comfyui-ergouzi-Nodes.git || true

# Res4Lyf nodes (for Sigmas Split Value)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/ClownsharkBatwing/RES4LYF.git && \
    cd RES4LYF && pip install -r requirements.txt || true

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
