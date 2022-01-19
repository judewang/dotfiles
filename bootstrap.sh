echo "Add default packages to nvm config"
touch $HOME/.nvm/default-packages
echo -e "@sanity/cli\nvercel\ncommitizen\ncz-conventional-changelog" >> $HOME/.nvm/default-packages
echo "All done now!"
