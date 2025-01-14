#!/bin/sh

git clone https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

rm -f "${ZDOTDIR:-$HOME}"/.zlogin
rm -f "${ZDOTDIR:-$HOME}"/.zlogout
rm -f "${ZDOTDIR:-$HOME}"/.zprofile
rm -f "${ZDOTDIR:-$HOME}"/.zshenv

ln -s "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/zlogin "${ZDOTDIR:-$HOME}"/.zlogin
ln -s "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/zlogout "${ZDOTDIR:-$HOME}"/.zlogout
ln -s "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/zprofile "${ZDOTDIR:-$HOME}"/.zprofile
ln -s "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/zshenv "${ZDOTDIR:-$HOME}"/.zshenv
