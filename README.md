# ComfyUI I2V Worker for RunPod Serverless

Custom ComfyUI worker optimized for Image-to-Video generation using Wan2.2 I2V models.

## Configuration

| Setting | Value |
|---------|-------|
| **Region** | EU-RO-1 (Romania) |
| **GPU** | A100 80GB |

## Setup

### 1. Populate Network Volume

Upload models via S3 API:

```bash
# Configure AWS CLI
aws configure --profile runpod
# Access Key: your_runpod_user_id
# Secret Key: your_s3_api_key
# Region: eu-ro-1

# Upload models
aws s3 sync ./models s3://YOUR_VOLUME_ID/models/ \
  --profile runpod \
  --region eu-ro-1 \
  --endpoint-url https://s3api-eu-ro-1.runpod.io/
```

### 2. Create Serverless Endpoint

1. Go to [RunPod Serverless](https://www.runpod.io/console/serverless)
2. Create **Template**:
   - **Container Image**: `ghcr.io/zikki1981/worker-comfyui-i2v:latest`
   - **Container Disk**: 20GB
   - **Volume Mount Path**: `/runpod-volume`
3. Create **Endpoint**:
   - Select your template
   - **GPU**: A100 80GB
   - **Network Volume**: Your volume ID
   - **Active Workers**: 0-1
   - **Max Workers**: 1
   - **Idle Timeout**: 5 minutes

## API Usage

```python
import requests
import base64
import json
import time

RUNPOD_API_KEY = "your_api_key"
ENDPOINT_ID = "your-endpoint-id"

# Load workflow JSON (exported from ComfyUI)
with open("workflow_api.json") as f:
    workflow = json.load(f)

# Encode input image
with open("input.png", "rb") as f:
    image_b64 = base64.b64encode(f.read()).decode()

# Submit job
response = requests.post(
    f"https://api.runpod.ai/v2/{ENDPOINT_ID}/run",
    headers={
        "Authorization": f"Bearer {RUNPOD_API_KEY}",
        "Content-Type": "application/json"
    },
    json={
        "input": {
            "workflow": workflow,
            "images": [{"name": "input.png", "image": image_b64}]
        }
    }
)

job_id = response.json()["id"]

# Poll for result
while True:
    status = requests.get(
        f"https://api.runpod.ai/v2/{ENDPOINT_ID}/status/{job_id}",
        headers={"Authorization": f"Bearer {RUNPOD_API_KEY}"}
    ).json()

    if status["status"] == "COMPLETED":
        # Videos are in 'videos' field (new handler), fallback to 'images'
        output = status["output"]
        if "videos" in output and output["videos"]:
            video_b64 = output["videos"][0]["data"]
        else:
            video_b64 = output["images"][0]["data"]

        with open("output.mp4", "wb") as f:
            f.write(base64.b64decode(video_b64))
        break
    elif status["status"] == "FAILED":
        print(f"Failed: {status}")
        break

    time.sleep(3)
```

## Models Required

### Diffusion Models (`/models/diffusion_models/Wan2.2/`)
- `wan2.2_i2v_high_noise_14B_fp16.safetensors`
- `wan2.2_i2v_low_noise_14B_fp16.safetensors`

### Text Encoders (`/models/text_encoders/`)
- `umt5_xxl_fp16.safetensors`

### VAE (`/models/vae/`)
- `wan_2.1_vae.safetensors`
- `wan2.2_vae.safetensors`

### LoRAs (`/models/loras/`)
- `SVI_Wan2.2-I2V-A14B_high_noise_lora_v2.0_pro.safetensors`
- `SVI_Wan2.2-I2V-A14B_low_noise_lora_v2.0_pro.safetensors`
- `lightx2v_I2V_14B_480p_cfg_step_distill_rank256_bf16.safetensors`
- Your custom I2V LoRAs

## Custom Handler with Video Support

This worker uses a custom handler (`src/handler.py`) based on [PR #133](https://github.com/runpod-workers/worker-comfyui/pull/133) to support video outputs.

**Why?** The base `runpod/worker-comfyui` handler only collects `images` from ComfyUI outputs. Video generation nodes like `VHS_VideoCombine` output MP4 files in a field called `gifs` which the base handler ignores.

**Changes:**
- Videos are fetched via ComfyUI's `/view` endpoint (same as images)
- Videos are returned in a separate `videos` field in the response
- Supports both S3 upload and base64 encoding (fallback)

**Response format:**
```json
{
  "output": {
    "images": [],
    "videos": [
      {"filename": "video.mp4", "type": "base64", "data": "AAAA..."}
    ]
  },
  "status": "COMPLETED"
}
```

## VIP Worker Integration

The `vip_worker.py` on VixenVision applies optimizations before sending workflows to RunPod:

1. **GPU cleanup muting**: Nodes like `easy cleanGpuUsed` are muted (`is_muted: true`) since RunPod workers have dedicated GPUs - no need to purge VRAM between jobs.

2. **Video retrieval**: Checks both `videos` (new handler) and `images` (fallback) fields.

## Custom Nodes (in Docker image)

- ComfyUI-WanVideoWrapper
- ComfyUI-VideoHelperSuite
- ComfyUI-KJNodes
- rgthree-comfy
- ComfyUI-Impact-Pack
- ComfyUI-Frame-Interpolation
- comfyui-florence2

## Cost Estimation

| Item | Cost |
|------|------|
| A100 80GB | ~$1.89/hour |
| Avg generation | 45-70 seconds |
| Cost per generation | ~$0.025-0.035 |
| Network Volume (100GB) | ~$10/month |

## Building the Docker Image

```bash
git clone https://github.com/Zikki1981/worker-comfyui-i2v.git
cd worker-comfyui-i2v
docker build -t ghcr.io/zikki1981/worker-comfyui-i2v:latest .
docker push ghcr.io/zikki1981/worker-comfyui-i2v:latest
```

## License

MIT
