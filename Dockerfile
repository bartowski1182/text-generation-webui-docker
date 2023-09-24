# cuda devel image for base, best build compatibility
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04 as builder

# Using conda to transfer python env from builder to runtime later
COPY --from=continuumio/miniconda3:23.5.2-0 /opt/conda /opt/conda
ENV PATH=/opt/conda/bin:$PATH

# Update base image
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y git build-essential \
    ocl-icd-opencl-dev opencl-headers clinfo \
    && mkdir -p /etc/OpenCL/vendors && echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

# Create new conda environment
RUN conda create -y -n textgen python=3.10.9
SHELL ["conda", "run", "-n", "textgen", "/bin/bash", "-c"]

ENV CUDA_DOCKER_ARCH=all

# Installing torch and ninja
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

RUN pip3 install ninja packaging

RUN MAX_JOBS=4 pip3 install flash-attn --no-build-isolation 

ARG commithash=.

# Pulling latest text-generation-webui branch
RUN git clone https://github.com/oobabooga/text-generation-webui.git  \
    && cd text-generation-webui && git checkout $commit \
    && pip3 install -r requirements.txt

# Install all the extension requirements
RUN bash -c 'for i in text-generation-webui/extensions/*/requirements.txt ; do pip3 install -r $i ; done'

# Prepare cache for faster first time runs NOTE: This is currently broken on master, will re-add when it's fixed: https://github.com/oobabooga/text-generation-webui/pull/3995
#RUN cd /text-generation-webui/extensions/openai/ && python3 cache_embedding_model.py

RUN conda clean -afy

# Using fully set up runtime for smaller final image with proper drivers
FROM noneabove1182/nvidia-runtime-docker:11.8.0-runtime-ubuntu22.04

# Copy conda and cuda files over
COPY --from=builder /opt/conda /opt/conda
COPY --from=builder /usr/local/cuda-11.8/targets/x86_64-linux/include /usr/local/cuda-11.8/targets/x86_64-linux/include 

ENV PATH=/opt/conda/bin:$PATH

# Copy git repo from builder
COPY --from=builder /text-generation-webui /text-generation-webui

# Setting frontend to noninteractive to avoid getting locked on keyboard input
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
