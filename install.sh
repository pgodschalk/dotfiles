#!/bin/sh

git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
git clone --recurse-submodules https://github.com/belak/prezto-contrib "${ZDOTDIR:-$HOME}/.zprezto/contrib"

rm -f "${ZDOTDIR:-$HOME}"/.zlogin
rm -f "${ZDOTDIR:-$HOME}"/.zlogout
rm -f "${ZDOTDIR:-$HOME}"/.zprofile
rm -f "${ZDOTDIR:-$HOME}"/.zshenv

ln -s "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/zlogin "${ZDOTDIR:-$HOME}"/.zlogin
ln -s "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/zlogout "${ZDOTDIR:-$HOME}"/.zlogout
ln -s "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/zprofile "${ZDOTDIR:-$HOME}"/.zprofile
ln -s "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/zshenv "${ZDOTDIR:-$HOME}"/.zshenv

mkdir -p "$HOME/.config"
cp .config/starship.toml "$HOME/.config/starship.toml"

mkdir -p "$HOME/Code"
cp -R bin "$HOME/Code/bin"

cp .aliases "$HOME/.aliases"
cp .curlrc "$HOME/.curlrc"
cp .exports "$HOME/.exports"
cp .functions "$HOME/.functions"
cp .gitattributes "$HOME/.gitattributes"
cp .gitconfig "$HOME/.gitconfig"
cp .gitignore_global "$HOME/.gitignore"
cp .hushlogin "$HOME/.hushlogin"
cp .inputrc "$HOME/.inputrc"
cp .nanorc "$HOME/.nanorc"
cp .screenrc "$HOME/.screenrc"
cp .sources "$HOME/.sources"
cp .wgetrc "$HOME/.wgetrc"
cp .zmodules "$HOME/.zmodules"
cp .zpreztorc "$HOME/.zpreztorc"
cp .zshrc "$HOME/.zshrc"
