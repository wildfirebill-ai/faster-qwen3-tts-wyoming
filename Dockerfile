FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

ARG TORCH_VERSION=2.7.1

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PATH="/opt/venv/bin:${PATH}" \
    PYTHONPATH="/app" \
    HF_HOME="/config/huggingface" \
    TRANSFORMERS_CACHE="/config/huggingface" \
    GRADIO_TEMP_DIR="/config/gradio" \
    TORCH_HOME="/config/torch" \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        ffmpeg \
        git \
        gosu \
        libsndfile1 \
        pkg-config \
        python3 \
        python3-dev \
        python3-pip \
        python3-venv \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv \
    && python -m pip install --upgrade pip setuptools wheel \
    && python -m pip install \
        "torch==${TORCH_VERSION}+cu118" \
        "torchaudio==${TORCH_VERSION}+cu118" \
        "transformers==4.57.3" \
        "faster-qwen3-tts==0.3.2" \
        "gradio==6.17.3" \
        "huggingface-hub==0.36.2" \
        "fastapi==0.139.2" \
        "uvicorn==0.51.0" \
        "httpx==0.28.1" \
        "soundfile==0.14.0" \
        "wyoming>=1.8,<2" \
        --extra-index-url https://download.pytorch.org/whl/cu118

# Build qwentts-cpp-python native library (libqwen.so) for CUDA 11.8
RUN git clone --recurse-submodules https://github.com/andimarafioti/qwentts-cpp-python.git /tmp/qwentts-cpp-python \
    && cd /tmp/qwentts-cpp-python \
    && python scripts/build_native.py --backend cuda --clean \
    && python -m pip install .

COPY app /app
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod 0755 /usr/local/bin/docker-entrypoint.sh \
    && mkdir -p /config

ARG VERSION=dev
ARG VCS_REF=unknown
ARG BUILD_DATE=unknown

ENV APP_VERSION=${VERSION}

LABEL org.opencontainers.image.title="Faster Qwen3-TTS with Wyoming" \
      org.opencontainers.image.description="Local Qwen3-TTS API, WebUI, and Wyoming TTS server for Unraid" \
      org.opencontainers.image.source="https://github.com/wildfirebill-ai/faster-qwen3-tts-wyoming" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.created="${BUILD_DATE}"

VOLUME ["/config"]
EXPOSE 7860 10210

HEALTHCHECK --interval=30s --timeout=10s --start-period=20m --retries=3 \
    CMD ["python", "/app/healthcheck.py"]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["python", "-m", "launcher"]
