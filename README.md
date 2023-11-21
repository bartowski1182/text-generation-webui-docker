## This work is not official

I am providing this work as a helpful hand to people who are looking for a simple, easy to build docker image with GPU support, this is not official in any capacity, and any issues arising from this docker image should be posted here and not on their own repo or discord.

Instructions for getting nvidia docker set up: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html

BREAKING CHANGE:

As of 2023-10-24 the CUDA version is now 12.1 to support the change from Oobabooga being updated to 12.1. As such, the base images have been updated as has my nvidia-runtime-docker-for-llms image.

Known working with nvidia driver 535.129, may work on other versions

# text-generation-webui-docker

Docker images and configuration to run [text-generation-webui](https://github.com/oobabooga/text-generation-webui/) with GPU, currently being based off of latest commit whenever I feel like updating it, but the goal of this is to allow you to create it yourself with a clear concise Dockerfile that's understandable and transparent.

I am using noneabove1182/nvidia-runtime-docker:12.1.1-runtime-ubuntu22.04-535.129 for my final build stage to speed up subsequent builds, since it always starts with a long process that isn't ACTUALLY affected by previous build stage being changed, but docker build doesn't know that. It's simply taking the nvidia/cuda:12.1.1-runtime-ubuntu22.04 and updating packages and setting up proper driver versions such as 535.129

Here's a link to what that container is built from:
https://github.com/noneabove1182/nvidia-runtime-docker-for-llms

# Special tweaks

The included start.sh script will parse all the extensions in your local extensions folder, install their requirements, and symlink them into the docker volume for extensions. This means that after you add extensions you will have to restart your image to pick up the new changes, but you don't have to load any of them manually, just drop them into the folder you specify in your compose or run command.

The start.sh also links folders for models, loras, prompts, presets, characters, and logs. All of these should be linked into the docker image at the root ('/') directory (ex: local_dir:/models)

Models, prompts, presets, and characters will all copy the latest files from oobabooga's repo, so you're free to add new files for any changes you want to make, and other files will be kept up to date. Loras act similarly but without copying anything from latest, since there's nothing there by default.

Logs are good to include so you can keep your chat history. Docker will not save any files that aren't stored externally when recreated, so if you want persistence you'll need to specify a log folder in your compose or run command.

# Build instructions

First checkout this branch

```sh
git clone https://github.com/noneabove1182/text-generation-webui-docker.git
```

Next, build the image. This will use the latest from the text-generation-webui repository unless you pass a specific commit hash with --build-arg commithash={desired commit}

```sh
cd text-generation-webui-docker
docker build -t text-generation-webui-docker:latest .
```

Alternatively you can run the build script, which will also just pull latest unless you have a COMMITHASH variable in a .env file or specify a commit while running the script like below:

```sh
cd text-generation-webui-docker
./build.sh 7a3ca2c68f1ca49ac4e4b62f016718556fd3805c
```

(note it will call it noneabove1182/text-generation-webui-docker since that's what I use, and tag it as well, may change this later)

# Running the image with docker run

```sh
docker run --gpus all -p 7860:7860 -v /media/teamgroup/models:/models -v ./logs:/logs text-generation-webui-docker:latest --model WizardLM-13B-V1.1-GPTQ --chat --listen --listen-port 7860
```

# Running the image with docker compose

A docker-compose.yaml file has been provided, as well as a .env file that I use for setting my model dir and the model name I'd like to load in with

Feel free to modify both to fit your needs, including removing volumes like extensions if you don't plan on using any.

# Pre-built image

Pre-built images are provided at https://hub.docker.com/r/noneabove1182/text-gen-ui-gpu

Follow the same command as above except with noneabove1182/text-gen-ui-gpu:(version) or use the included docker-compose.yml
