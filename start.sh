#!/bin/bash

# Remove the models directory and create a symbolic link

if [[ -d /models ]] ; then
    echo "Found models, copying repo config.yaml to local and linking the directory"
    cp -R /text-generation-webui/models/config.yaml /models
    rm -r /text-generation-webui/models
    ln -s /models /text-generation-webui/models
else
    echo "No models DIR"
fi

if [[ -d /loras ]] ; then
    echo "Found loras, linking the directory"
    rm -r /text-generation-webui/loras
    ln -s /loras /text-generation-webui/loras
else
    echo "No loras DIR"
fi

if [[ -d /datasets ]] ; then
    echo "Found datasets, linking the directory"
    rm -r /text-generation-webui/training/datasets
    ln -s /datasets /text-generation-webui/training/datasets
else
    echo "No datasets DIR"
fi


if [[ -d /prompts ]] ; then
    echo "Found prompts, copying repo prompts to local and linking the directory"
    cp -R /text-generation-webui/prompts/. /prompts
    rm -r /text-generation-webui/prompts
    ln -s /prompts /text-generation-webui/prompts
else
    echo "No prompts DIR"
fi

if [[ -d /presets ]] ; then
    echo "Found presets, copying repo presets to local and linking the directory"
    cp -R /text-generation-webui/presets/. /presets
    rm -r /text-generation-webui/presets
    ln -s /presets /text-generation-webui/presets
else
    echo "No presets DIR"
fi

if [[ -d /characters ]] ; then
    echo "Found characters, copying repo characters to local and linking the directory"
    cp -R /text-generation-webui/characters/. /characters
    rm -r /text-generation-webui/characters
    ln -s /characters /text-generation-webui/characters
else
    echo "No characters DIR"
fi

if [[ -d /extensions ]] ; then
    echo "Found extensions, installing them then linking local extensions to container folder"
    local_extensions=($(find '/extensions' -mindepth 1 -maxdepth 1 -type d -printf '%f\n'))
    for extension in ${local_extensions[@]}; do
        conda run --no-capture-output -n textgen pip3 install -r /extensions/${extension}/requirements.txt
        ln -s /extensions/${extension} /text-generation-webui/extensions/
    done
else
    echo "No extensions DIR"
fi

if [[ -d /logs ]] ; then
    echo "Found logs, linking to logs folder in repo to save between sessions"
    ln -s /logs /text-generation-webui/logs
else
    echo "No logs DIR"
fi

# Start the server
conda run --no-capture-output -n textgen python server.py "$@"
