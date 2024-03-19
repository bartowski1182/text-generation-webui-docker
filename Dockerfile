# cuda devel image for base, best build compatibility
FROM nvidia/cuda:12.1.1-devel-ubuntu22.04 as builder

# Using conda to transfer python env from builder to runtime later
COPY --from=continuumio/miniconda3:23.10.0-1 /opt/conda /opt/conda
ENV PATH=/opt/conda/bin:$PATH

# Update base image
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y git build-essential \
    ocl-icd-opencl-dev opencl-headers clinfo \
    && mkdir -p /etc/OpenCL/vendors && echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

# Create new conda environment
RUN conda create -y -n textgen python=3.11.8
SHELL ["conda", "run", "-n", "textgen", "/bin/bash", "-c"]

ENV CUDA_DOCKER_ARCH=all

ARG CACHEBUST=1

# Installing torch and ninja
RUN pip3 install torch==2.2.* torchvision==0.17.* torchaudio==2.2.* xformers --index-url https://download.pytorch.org/whl/cu121

RUN pip3 install ninja packaging sentence-transformers

ARG clone_arg
ARG commit

# Pulling latest text-generation-webui branch
RUN git clone https://github.com/oobabooga/text-generation-webui/ $clone_arg \
    && cd text-generation-webui \
    && if [ -n "$commit" ]; then git checkout $commit; fi \
    && pip3 install -r requirements.txt --upgrade

# Install all the extension requirements
RUN bash -c 'for i in text-generation-webui/extensions/*/requirements.txt ; do pip3 install -r $i ; done'

RUN conda clean -afy

# Using ubuntu 22.04 for runtime
FROM ubuntu:22.04

# Copy conda over
COPY --from=builder /opt/conda /opt/conda
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV PATH=/opt/conda/bin:$PATH

# Copy git repo from builder
COPY --from=builder /text-generation-webui /text-generation-webui

ENV CUDA_DOCKER_ARCH=all

# Set the working directory
WORKDIR /text-generation-webui

EXPOSE 7860
EXPOSE 5000

# start.sh sets up the various available directories like models and characters
# installs requirements for any user-included extensions
# Also provides a conda env activated entrypoint
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Define the entrypoint
ENTRYPOINT ["/start.sh"]
