#!/bin/bash

echo "Add default packages to nvm config"
touch $HOME/.nvm/default-packages
echo -e "@sanity/cli\nvercel\ncommitizen\ncz-conventional-changelog" >> $HOME/.nvm/default-packages

echo "Copy VNC resources"

TMPDIR=$(mktemp -d)

cd $TMPDIR

for file in ~/.dotfiles/files/*; do
  cp $file $GITPOD_REPO_ROOT
done

echo "Check Gitpod config"

FILE=${GITPOD_REPO_ROOT}/.gitpod
if [ -f "$FILE" ]; then
    echo "$FILE exists. Skip copy .gitpod"
else 
    echo "$FILE does not exist. Copying default .gitpod"
    cp ~/.dotfiles/.gitpod.example ${GITPOD_REPO_ROOT}/.gitpod
fi

cd $GITPOD_REPO_ROOT

rm -rf $TMPDIR

echo "All done now!"
