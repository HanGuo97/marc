# syntax = docker/dockerfile:1.0-experimental
FROM pytorch/pytorch:2.5.1-cuda12.1-cudnn9-devel

# working directory
WORKDIR /workspace

# ---------------------------------------------
# Project-agnostic System Dependencies
# ---------------------------------------------
RUN \
    # Install System Dependencies
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        wget \
        unzip \
        psmisc \
        vim \
        git \
        ssh \
        curl && \
    rm -rf /var/lib/apt/lists/*

# https://pythonspeed.com/articles/activate-virtualenv-dockerfile/# 
RUN python3 -m venv /opt/venv-ttt
RUN python3 -m venv /opt/venv-inference

# ---------------------------------------------
# Build Python depencies and utilize caching
# ---------------------------------------------
COPY ./requirements.txt /workspace/main/requirements.txt
COPY ./requirements-ttt.txt /workspace/main/requirements-ttt.txt
COPY ./requirements-inference.txt /workspace/main/requirements-inference.txt

RUN . /opt/venv-ttt/bin/activate && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /workspace/main/requirements.txt && \
    pip install --no-cache-dir -r /workspace/main/requirements-ttt.txt

RUN . /opt/venv-inference/bin/activate && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /workspace/main/requirements.txt && \
    pip install --no-cache-dir -r /workspace/main/requirements-inference.txt

# upload everything
COPY . /workspace/main/

# Set HOME
ENV HOME="/workspace/main"

# Reset Entrypoint from Parent Images
# https://stackoverflow.com/questions/40122152/how-to-remove-entrypoint-from-parent-image-on-dockerfile/40122750
ENTRYPOINT []

# load bash
CMD /bin/bash