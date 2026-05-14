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
    comfyui-mxtoolkit

# TinyTerraNodes - install from GitHub (registry name has issues)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/TinyTerra/ComfyUI_tinyterraNodes.git

# WanVideoWrapper - install from GitHub for latest version with WanVideoApplyNAG

RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git && \
    cd ComfyUI-WanVideoWrapper && pip install -r requirements.txt || true

# FramePackWrapper (original by kijai) - contains FramePackFindNearestBucket
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-FramePackWrapper.git && \
    cd ComfyUI-FramePackWrapper && pip install -r requirements.txt || true

# FramePackWrapper_Plus (extended version)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/ShmuelRonen/ComfyUI-FramePackWrapper_Plus.git && \
    cd ComfyUI-FramePackWrapper_Plus && pip install -r requirements.txt || true

# Ergouzi nodes (for EG_WXZ_QH) - create web/extensions folder first to fix import error
RUN mkdir -p /comfyui/web/extensions/EG_GN_NODES && \
    cd /comfyui/custom_nodes && \
    git clone https://github.com/11dogzi/Comfyui-ergouzi-Nodes.git || true

# Res4Lyf nodes (for Sigmas Split Value)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/ClownsharkBatwing/RES4LYF.git && \
    cd RES4LYF && pip install -r requirements.txt || true

# FL_RIFE and other FL nodes (filliptm/ComfyUI_Fill-Nodes)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/filliptm/ComfyUI_Fill-Nodes.git && \
    cd ComfyUI_Fill-Nodes && pip install -r requirements.txt || true

# Additional nodes from workflow
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/Kangkang625/ComfyUI-Addoor.git || true && \
    git clone https://github.com/spacepxl/ComfyUI-pause.git || true

# K3NK custom nodes (from K3NK workflow)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/K3NK/ComfyUI-K3NKImageGrab.git || true

# ============================================
# BUILD TOOLS - Required for Triton JIT compilation
# ============================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# SAGEATTENTION - Required for attention_mode: sageattn in workflows
# Same version as Olares (1.0.6)
# ============================================
RUN pip install --no-cache-dir sageattention==1.0.6

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
