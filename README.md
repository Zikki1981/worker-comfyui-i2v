# ComfyUI I2V Worker for RunPod Serverless

Custom ComfyUI worker optimized for Image-to-Video generation using Wan2.2 I2V models.

## Features

- **Wan2.2 I2V 14B** - High quality image-to-video generation
- **SVI Pro LoRAs** - Enhanced video quality
- **LightX2V** - 4-step distillation for faster inference
- **Custom LoRAs** - Support for CivitAI LoRAs

## Quick Start

### 1. Build the Docker image

```bash
docker build -t your-dockerhub/worker-comfyui-i2v:latest .
docker push your-dockerhub/worker-comfyui-i2v:latest
```

### 2. Create RunPod Serverless Endpoint

1. Go to [RunPod Serverless](https://www.runpod.io/console/serverless)
2. Create new endpoint
3. Use your Docker image: `your-dockerhub/worker-comfyui-i2v:latest`
4. Select GPU: **H100 SXM** (recommended) or **A100 80GB**
5. Set idle timeout: 5-10 minutes

### 3. API Usage

```python
import requests

RUNPOD_API_KEY = "your-api-key"
ENDPOINT_ID = "your-endpoint-id"

# Submit job
response = requests.post(
    f"https://api.runpod.ai/v2/{ENDPOINT_ID}/run",
    headers={
        "Authorization": f"Bearer {RUNPOD_API_KEY}",
        "Content-Type": "application/json"
    },
    json={
        "input": {
            "workflow": workflow_json,  # Your ComfyUI workflow
            "images": [
                {
                    "name": "input.png",
                    "image": "base64_encoded_image"
                }
            ]
        }
    }
)

job_id = response.json()["id"]

# Poll for result
status_response = requests.get(
    f"https://api.runpod.ai/v2/{ENDPOINT_ID}/status/{job_id}",
    headers={"Authorization": f"Bearer {RUNPOD_API_KEY}"}
)
```

## Adding Custom LoRAs

Edit the `Dockerfile` and add your CivitAI LoRAs:

```dockerfile
RUN curl -L -o /comfyui/models/loras/your_lora.safetensors \
    "https://civitai.com/api/download/models/VERSION_ID?token=YOUR_CIVITAI_TOKEN"
```

## Models Included

### Diffusion Models
- `wan2.2_i2v_high_noise_14B_fp16.safetensors` (~14GB)
- `wan2.2_i2v_low_noise_14B_fp16.safetensors` (~14GB)

### Text Encoders
- `umt5_xxl_fp16.safetensors` (~10GB)

### VAE
- `wan_2.1_vae.safetensors`
- `wan2.2_vae.safetensors`

### LoRAs
- `SVI_Wan2.2-I2V-A14B_high_noise_lora_v2.0_pro.safetensors`
- `SVI_Wan2.2-I2V-A14B_low_noise_lora_v2.0_pro.safetensors`
- `lightx2v_I2V_14B_480p_cfg_step_distill_rank256_bf16.safetensors`

## Custom Nodes

- ComfyUI-WanVideoWrapper
- ComfyUI-VideoHelperSuite
- ComfyUI-KJNodes
- rgthree-comfy
- ComfyUI-Impact-Pack
- ComfyUI-Frame-Interpolation
- comfyui-florence2

## Cost Estimation

- **H100 SXM**: ~$2.39/hour
- **A100 80GB**: ~$1.89/hour
- **Average I2V generation**: 30-60 seconds
- **Cost per generation**: ~$0.02-0.04

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `COMFY_POLLING_INTERVAL` | Polling interval in ms | 500 |
| `COMFY_POLLING_MAX_RETRIES` | Max polling retries | 300 |

## License

MIT
