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

cd $CURRENT

rm -rf $TMPDIR

echo "All done now!"
