#!/bin/bash

# No more use nvm in workspace
# echo "Add default packages to nvm config"
# touch $HOME/.nvm/default-packages
# echo -e "@sanity/cli\nvercel\ncommitizen\ncz-conventional-changelog" >> $HOME/.nvm/default-packages

echo "Check Gitpod config"

FILE=${GITPOD_REPO_ROOT}/.gitpod.yml
if [ -f "$FILE" ]; then
    echo "$FILE exists. Skip copy .gitpod.yml"
else
    echo "$FILE does not exist. Copying default .gitpod.yml"
    cp ~/.dotfiles/.gitpod.yml ${GITPOD_REPO_ROOT}/.gitpod.yml
    cp ~/.dotfiles/.gitpod.Dockerfile ${GITPOD_REPO_ROOT}/.gitpod.Dockerfile
    # echo "Copy VNC resources"
    # cp -r ~/.dotfiles/files/. $GITPOD_REPO_ROOT
fi

cd $GITPOD_REPO_ROOT

echo "All done now!"
