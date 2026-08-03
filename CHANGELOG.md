# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-08-03

### Added
- Initial release of Faster Qwen3-TTS with Wyoming integration
- CUDA 11.8 support for Maxwell GPUs (Tesla M40, K80, compute capability 5.2)
- OpenAI-compatible TTS API at `/v1/audio/speech`
- Wyoming TTS protocol adapter on port 10210 for Home Assistant
- Gradio WebUI at `/ui/` for testing voices and settings
- Support for Qwen3-TTS 1.7B and 0.6B CustomVoice models
- Multi-speaker support (aiden, dylan, eric, ono_anna, ryan, serena, sohee, uncle_fu, vivian)
- Streaming PCM/WAV audio output
- Docker Compose deployments (compose.1.7b.yaml, compose.0.6b.yaml)
- Unraid Community Applications template
- Portainer stack support
- GPU resource reservation via NVIDIA Container Toolkit

### Changed
- Switched from ggml backend to torch backend (default in faster-qwen3-tts) for better compatibility
- Removed qwentts-cpp-python native build dependency
- Reduced build time from 51+ min to ~13 min
- Reduced image size from ~3.5-4.5 GB to ~2-2.5 GB
- Changed base image from nvidia/cuda:11.8-devel to nvidia/cuda:11.8-runtime
- Default backend changed from "ggml" to "torch"

### Fixed
- Maxwell GPU (CC 5.2) support with CUDA 11.8
- max_new_tokens limit increased from 4096 to 32768
- Dependency conflicts between faster-qwen3-tts and qwentts-cpp-python
- ABI version mismatch requiring qwentts.cpp v2 symbols

## [0.1.0] - 2026-07-30

### Added
- Initial development version
- Basic Qwen3-TTS integration with Wyoming protocol
- Docker and Unraid deployment configurations