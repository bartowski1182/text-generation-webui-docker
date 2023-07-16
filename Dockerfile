# Use nvidia/cuda as a builder base
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04 as builder

COPY --from=continuumio/miniconda3:4.12.0 /opt/conda /opt/conda

ENV PATH=/opt/conda/bin:$PATH

# Update the base image
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y git build-essential \
    ocl-icd-opencl-dev opencl-headers clinfo \
    && mkdir -p /etc/OpenCL/vendors && echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

# Create a new environment
RUN conda create -y -n textgen python=3.10.9
SHELL ["conda", "run", "-n", "textgen", "/bin/bash", "-c"]

RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

RUN pip3 install ninja

RUN pip3 uninstall -y llama-cpp-python \
    && CMAKE_ARGS="-DLLAMA_CUBLAS=on" FORCE_CMAKE=1 pip3 install llama-cpp-python==0.1.72 --no-cache-dir

RUN git clone https://github.com/TimDettmers/bitsandbytes.git \
    && cd bitsandbytes && git checkout 37c25c1e0db6b61d9a55ff5d6879eb50a10326e7 \
    && CUDA_VERSION=118 make cuda11x \
    && python3 setup.py install

RUN git clone https://github.com/oobabooga/text-generation-webui.git --branch v1.2 \
    && cd text-generation-webui && pip3 install -r requirements.txt

RUN bash -c 'for i in text-generation-webui/extensions/*/requirements.txt ; do pip3 install -r $i ; done'

RUN python3 text-generation-webui/extensions/openai/cache_embedding_model.py

RUN conda clean -afy

# Now use a smaller image for the final step
FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

COPY --from=builder /opt/conda /opt/conda
COPY --from=builder /usr/local/cuda-11.8/targets/x86_64-linux/include /usr/local/cuda-11.8/targets/x86_64-linux/include 

ENV PATH=/opt/conda/bin:$PATH

COPY --from=builder /text-generation-webui /text-generation-webui

RUN apt-get update && apt-get upgrade -y \
    && apt-get -y install python3 build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir -p /etc/OpenCL/vendors

COPY --from=builder /etc/OpenCL/vendors/nvidia.icd /etc/OpenCL/vendors/nvidia.icd

# Set the working directory
WORKDIR /text-generation-webui

EXPOSE 7860
EXPOSE 5000

# Make the script executable
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Define the entrypoint
ENTRYPOINT ["/start.sh"]
