#!/bin/bash

echo "Add default packages to nvm config"
touch $HOME/.nvm/default-packages
echo -e "@sanity/cli\nvercel\ncommitizen\ncz-conventional-changelog" >> $HOME/.nvm/default-packages

echo "Copy VNC resources"

TMPDIR=$(mktemp -d)

CURRENT=$PWD

cd $TMPDIR

for file in ~/.dotfiles/files/*; do
  cp file $CURRENT
done

echo "Check Gitpod config"

FILE=${CURRENT}/.gitpod
if [ -f "$FILE" ]; then
    echo "$FILE exists. Skip copy .gitpod"
else 
    echo "$FILE does not exist. Copying default .gitpod"
    cp ~/.dotfiles/.gitpod.example ${CURRENT}/.gitpod
fi

cd $CURRENT

rm -rf $TMPDIR

echo "All done now!"
