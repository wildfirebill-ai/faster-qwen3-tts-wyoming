# Faster Qwen3-TTS + Wyoming — Local GPU-Accelerated TTS for Docker & Unraid

[![GitHub Release](https://img.shields.io/github/v/release/wildfirebill-ai/faster-qwen3-tts-wyoming?label=release&sort=semver)](https://github.com/wildfirebill-ai/faster-qwen3-tts-wyoming/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/wildfirebill-ai/faster-qwen3-tts-wyoming)](https://github.com/wildfirebill-ai/faster-qwen3-tts-wyoming/pkgs/container/faster-qwen3-tts-wyoming)
[![GitHub License](https://img.shields.io/github/license/wildfirebill-ai/faster-qwen3-tts-wyoming)](LICENSE)
[![CUDA Version](https://img.shields.io/badge/CUDA-11.8-green)](https://developer.nvidia.com/cuda-11.8.0-download-archive)
[![GPU Support](https://img.shields.io/badge/GPU-Maxwell%20%7C%20Pascal%20%7C%20Ampere%20%7C%20Hopper-blue)](https://developer.nvidia.com/cuda-gpus)
[![Platform](https://img.shields.io/badge/Platform-Docker%20%7C%20Portainer%20%7C%20Unraid-orange)](https://github.com/wildfirebill-ai/faster-qwen3-tts-wyoming)
[![Architecture](https://img.shields.io/badge/Arch-linux%2Famd64-lightgrey)](#requirements)

Run a local **Faster Qwen3-TTS WebUI**, **OpenAI-compatible TTS API**, and **Wyoming TTS server** in one NVIDIA-enabled Docker container. Supports Docker Compose, Portainer, and Unraid Community Applications. The HTTP and Wyoming interfaces share a single loaded model instance for efficient GPU memory usage.

**Key features:** CUDA 11.8 Maxwell GPU support (Tesla M40, K80) • OpenAI-compatible `/v1/audio/speech` endpoint • Wyoming protocol for Home Assistant • Gradio WebUI • 1.7B & 0.6B CustomVoice models • Multi-speaker support • Streaming PCM/WAV output

| Interface | Default Address | Intended Use |
|---|---|---|
| Gradio WebUI | `http://HOST-IP:7860/ui/` | Test voices and generation settings |
| OpenAI-compatible API | `http://HOST-IP:7860/v1/audio/speech` | OpenAI-compatible TTS clients |
| Wyoming TTS | `HOST-IP:10210` | Home Assistant and Wyoming clients |

## Architecture

```text
Faster-Qwen3-TTS-Wyoming
├── Qwen3-TTS API + WebUI :7860
└── Wyoming TTS            :10210
        └── HTTP -> 127.0.0.1:7860/v1/audio/speech
```

The container starts Qwen3-TTS first, waits for its health endpoint, and then opens the Wyoming port. If either managed process exits unexpectedly, the launcher terminates the other process and exits with an error so Docker can restart the complete app.

## Requirements

- Linux AMD64 Docker host
- Docker Engine with Docker Compose or Docker Standalone Portainer
- CUDA-capable NVIDIA GPU (Maxwell CC 5.2+ / Pascal / Ampere / Hopper / Blackwell)
- NVIDIA driver ≥520.x and NVIDIA Container Toolkit
- ~8 GB VRAM recommended for default 1.7B model (0.6B model uses less)
- Internet access during first model download

Models are downloaded at first start and persisted under `/config`.

Before deploying, verify GPU access:

```bash
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

## Models

Choose one CustomVoice model:

| Compose File | Model | Use Case |
|---|---|---|
| `compose.1.7b.yaml` | `Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice` | Default; higher quality |
| `compose.0.6b.yaml` | `Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice` | Lower VRAM, faster startup |

Both models support the same CustomVoice speakers:

```text
aiden, dylan, eric, ono_anna, ryan, serena, sohee, uncle_fu, vivian
```

The two Compose files use the same ports and must not run simultaneously on the same host.

## Quick Start (Docker Compose)

```bash
git clone https://github.com/wildfirebill-ai/faster-qwen3-tts-wyoming.git
cd faster-qwen3-tts-wyoming

# Higher-quality 1.7B model
docker compose -f compose.1.7b.yaml up -d

# Or lower-VRAM 0.6B model
docker compose -f compose.0.6b.yaml up -d
```

Edit the Compose file to customize timezone, PUID/PGID, voice, language, or instruction.

Check the stack:

```bash
docker compose -f compose.1.7b.yaml ps
docker compose -f compose.1.7b.yaml logs -f qwen3-tts
```

Update to a newer version:

```bash
git pull
docker compose -f compose.1.7b.yaml pull
docker compose -f compose.1.7b.yaml up -d
```

Switch models without losing cached models:

```bash
docker compose -f compose.1.7b.yaml down
docker compose -f compose.0.6b.yaml up -d
```

## Maxwell GPU Support (Tesla M40, K80, etc.)

**The published GHCR images use CUDA 11.8 for Maxwell compatibility (compute capability 5.2).** 

Use the `-maxwell` tagged images:

```yaml
services:
  qwen3-tts:
    image: ghcr.io/wildfirebill-ai/faster-qwen3-tts-wyoming:latest-maxwell
    # or specific version: ghcr.io/wildfirebill-ai/faster-qwen3-tts-wyoming:1.0.0-maxwell
```

Or build locally:

```bash
docker build -t faster-qwen3-tts-wyoming:maxwell .
```

Requires NVIDIA driver ≥520.x on the host.

## Portainer

GPU assignment in Portainer is supported for NVIDIA GPUs on Docker Standalone environments.

1. Open **Stacks** → **Add stack** → **Repository**
2. Repository URL: `https://github.com/wildfirebill-ai/faster-qwen3-tts-wyoming`
3. Compose path: `compose.1.7b.yaml` or `compose.0.6b.yaml`
4. Deploy and wait for model download
5. Open `http://HOST-IP:7860/ui/`

Use only one model file per host unless you assign different ports and volumes. Keep the same Portainer stack name and do not remove its named volume when switching models.

See [Portainer GPU docs](https://docs.portainer.io/user/docker/containers/advanced) and [Docker Compose GPU docs](https://docs.docker.com/compose/how-tos/gpu-support/).

## Install on Unraid

Unraid 6.12+ with the NVIDIA Driver plugin required.

1. Open **Apps** → search `Faster Qwen3-TTS Wyoming`
2. Verify appdata path, WebUI port `7860`, Wyoming port `10210`
3. Select model, keep NVIDIA runtime enabled
4. Start container, wait for model download
5. Open `http://UNRAID-IP:7860/ui/`

Manual template install:

```text
https://raw.githubusercontent.com/wildfirebill-ai/faster-qwen3-tts-wyoming/main/templates/faster-qwen3-tts-wyoming.xml
```

Unraid persistent cache: `/mnt/user/appdata/faster-qwen3-tts-wyoming`

## Default Settings

```json
{
  "model": "Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice",
  "voice": "sohee",
  "language": "english",
  "temperature": 0.5,
  "top_p": 0.3,
  "top_k": 150,
  "repetition_penalty": 1.3,
  "do_sample": true,
  "seed": 0,
  "max_new_tokens": 4096,
  "non_streaming_mode": false,
  "streaming_chunk_size": 120,
  "token_safety_margin": 8.0,
  "max_segment_chars": 500,
  "segment_pause_ms": 120,
  "instruct": "Speak naturally, clearly, and warmly in English. Use a calm, fluent pace, lively but restrained prosody, and natural sentence pauses. Articulate sibilants and numbers clearly. Avoid monotonous intonation, exaggerated emotion, and dramatic pitch changes."
}
```

All settings can be changed via Compose environment or Unraid template. Existing container settings override image defaults after updates.

## OpenAI-Compatible API

Base URL: `http://HOST-IP:7860/v1`  
Model: `tts-1`  
Voice: `sohee`

Generate WAV:

```bash
curl http://HOST-IP:7860/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{"model":"tts-1","input":"This is a text-to-speech test.","voice":"sohee","language":"english","response_format":"wav"}' \
  --output qwen-test.wav
```

Stream raw 24 kHz mono PCM16:

```bash
curl http://HOST-IP:7860/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{"model":"tts-1","input":"This audio is streamed as PCM.","voice":"sohee","language":"english","response_format":"pcm","stream":true}' \
  --output qwen-test.pcm
```

Additional endpoints:

```bash
curl http://HOST-IP:7860/health
curl http://HOST-IP:7860/v1/voices
```

## Home Assistant Integration

Settings → Devices & services → Add integration → **Wyoming Protocol** → Connect to:

```text
Host: HOST-IP
Port: 10210
```

The configured language is advertised to Wyoming clients automatically.

## Troubleshooting

- First startup takes several minutes (model download + load)
- Unhealthy container? Check logs, verify NVIDIA GPU visible inside container
- 1.7B OOM? Switch to 0.6B model and restart
- Port in use? Change host port in Compose, Portainer, or Unraid template

## Security

WebUI and API have no authentication. Publish ports only on trusted LAN or behind authenticated reverse proxy. Container runs non-privileged.

## License & Upstream

MIT License for integration code, Compose files, and Unraid template. Upstream licenses apply:

- [QwenLM/Qwen3-TTS](https://github.com/QwenLM/Qwen3-TTS)
- [Qwen3-TTS 1.7B CustomVoice](https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice)
- [Qwen3-TTS 0.6B CustomVoice](https://huggingface.co/Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice)
- [Faster Qwen3-TTS](https://github.com/andimarafioti/faster-qwen3-tts)
- [qwentts-cpp-python](https://github.com/andimarafioti/qwentts-cpp-python)
- [OHF-Voice Wyoming](https://github.com/OHF-Voice/wyoming)

See [CONTRIBUTING.md](CONTRIBUTING.md) for development and validation instructions.
