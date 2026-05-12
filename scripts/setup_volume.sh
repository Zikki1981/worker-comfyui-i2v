#!/bin/bash
# Setup symlinks from Network Volume to ComfyUI models directories

VOLUME_PATH="/runpod-volume"
COMFYUI_PATH="/comfyui"

echo "=== Setting up Network Volume symlinks ==="

# Check if volume is mounted
if [ ! -d "$VOLUME_PATH/models" ]; then
    echo "WARNING: Network Volume not mounted at $VOLUME_PATH"
    echo "Models will not be available!"
    exit 0
fi

# Create symlinks for each model type
echo "Creating symlinks..."

# Diffusion models
if [ -d "$VOLUME_PATH/models/diffusion_models" ]; then
    rm -rf "$COMFYUI_PATH/models/diffusion_models"
    ln -sf "$VOLUME_PATH/models/diffusion_models" "$COMFYUI_PATH/models/diffusion_models"
    echo "  ✓ diffusion_models"
fi

# Text encoders
if [ -d "$VOLUME_PATH/models/text_encoders" ]; then
    rm -rf "$COMFYUI_PATH/models/text_encoders"
    ln -sf "$VOLUME_PATH/models/text_encoders" "$COMFYUI_PATH/models/text_encoders"
    echo "  ✓ text_encoders"
fi

# VAE
if [ -d "$VOLUME_PATH/models/vae" ]; then
    rm -rf "$COMFYUI_PATH/models/vae"
    ln -sf "$VOLUME_PATH/models/vae" "$COMFYUI_PATH/models/vae"
    echo "  ✓ vae"
fi

# LoRAs
if [ -d "$VOLUME_PATH/models/loras" ]; then
    rm -rf "$COMFYUI_PATH/models/loras"
    ln -sf "$VOLUME_PATH/models/loras" "$COMFYUI_PATH/models/loras"
    echo "  ✓ loras"
fi

# UNet (some LoRAs need to be here too)
if [ -d "$VOLUME_PATH/models/unet" ]; then
    rm -rf "$COMFYUI_PATH/models/unet"
    ln -sf "$VOLUME_PATH/models/unet" "$COMFYUI_PATH/models/unet"
    echo "  ✓ unet"
fi

# Workflows (optional)
if [ -d "$VOLUME_PATH/workflows" ]; then
    mkdir -p "$COMFYUI_PATH/user/default"
    rm -rf "$COMFYUI_PATH/user/default/workflows"
    ln -sf "$VOLUME_PATH/workflows" "$COMFYUI_PATH/user/default/workflows"
    echo "  ✓ workflows"
fi

echo "=== Volume setup complete ==="
echo ""
echo "Checking model availability:"
ls -la "$COMFYUI_PATH/models/" 2>/dev/null | head -10
echo ""
