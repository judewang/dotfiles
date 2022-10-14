#!/bin/bash

echo "Add default packages to nvm config"
touch $HOME/.nvm/default-packages
echo -e "@sanity/cli\nvercel\ncommitizen\ncz-conventional-changelog" >> $HOME/.nvm/default-packages

echo "Check Gitpod config"

FILE=${GITPOD_REPO_ROOT}/.gitpod.yml
if [ -f "$FILE" ]; then
    echo "$FILE exists. Skip copy .gitpod.yml"
else 
    echo "$FILE does not exist. Copying default .gitpod.yml"
    cp ~/.dotfiles/.gitpod.example ${GITPOD_REPO_ROOT}/.gitpod.yml
    echo "Copy VNC resources"
    cp ~/.dotfiles/files/. $GITPOD_REPO_ROOT
fi

cd $GITPOD_REPO_ROOT

echo "All done now!"
