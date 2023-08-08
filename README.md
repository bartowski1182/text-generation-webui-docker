## This work is not official

I am providing this work as a helpful hand to people who are looking for a simple, easy to build docker image with GPU support, this is not official in any capacity, and any issues arising from this docker image should be posted here and not on their own repo or discord.

Requires nvidia-driver 535.86.05, installed with apt-get install -y --allow-downgrades nvidia-driver-535/jammy-updates

# text-generation-webui-docker

Docker images and configuration to run text-generation-webui with GPU, currently updated to release v1.5 found here: https://github.com/oobabooga/text-generation-webui/releases/tag/v1.5

As of 1.5 I've added the ability to pass your own extensions! The start.sh script handles it, but basically it will parse all the extensions in your local extensions folder, install their requirements, and symlink them into the docker volume for extensions. This means that after you add extensions you will have to restart your image to pick up the new changes!

You can also pass folders for models, loras, prompts, presets, and characters

For all but loras, they will copy what is currently in master into your local folder, which means if you modify any of the presets or prompts, you should save them as a new file/name, or it will get overwritten next time you start (may look at fixing this if there's interest, open an issue)

# Build instructions

First checkout this branch

```sh
git clone https://github.com/noneabove1182/text-generation-webui-docker.git
```

Next, build the image

```sh
cd text-generation-webui-docker
docker build -t text-generation-webui-docker:latest .
```

# Running the image with docker run

```sh
docker run --gpus all -p 7860:7860 -v /media/teamgroup/models:/models text-generation-webui-docker:latest --model WizardLM-13B-V1.1-GPTQ --chat --listen --listen-port 7860
```

# Running the image with docker compose

A docker-compose.yaml file has been provided, as well as a .env file that I use for setting my model dir and the model name I'd like to load in with

Feel free to modify both to fit your needs, for example I prefer --no-stream but if you don't you can remove it

# Pre-built image

Pre-built images are provided at https://hub.docker.com/r/noneabove1182/text-gen-ui-gpu

Follow the same command as above except with noneabove1182/text-gen-ui-gpu:(version)
