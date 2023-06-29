#!/bin/bash

# Remove the models directory and create a symbolic link

if [[ -d /models ]] ; then
    cp /text-generation-webui/models/config.yaml /models
    rm -r /text-generation-webui/models
    ln -s /models /text-generation-webui/models
else
    echo "No models DIR"
fi

if [[ -d /loras ]] ; then
    rm -r /text-generation-webui/loras
    ln -s /loras /text-generation-webui/loras
else
    echo "No loras DIR"
fi

if [[ -d /prompts ]] ; then
    cp -R /text-generation-webui/prompts/. /prompts
    rm -r /text-generation-webui/prompts
    ln -s /prompts /text-generation-webui/loras
else
    echo "No prompts DIR"
fi

if [[ -d /presets ]] ; then
    cp /text-generation-webui/presets/. /presets
    rm -r /text-generation-webui/presets
    ln -s /presets /text-generation-webui/loras
else
    echo "No presets DIR"
fi

if [[ -d /characters ]] ; then
    cp -R /text-generation-webui/characters/. /characters
    rm -r /text-generation-webui/characters
    ln -s /characters /text-generation-webui/characters
else
    echo "No characters DIR"
fi



# Start the server
conda run --no-capture-output -n textgen python server.py "$@"
