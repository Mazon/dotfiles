#!/bin/bash
cp -r ~/.config/alacritty ~/dotfiles/config/alacritty
cp -r ~/.config/mango ~/dotfiles/config/mango
cp -r ~/.config/nvim ~/dotfiles/config/nvim
#cp -r ~/.config/waybar ~/dotfiles
cp -r ~/.zshrc ~/dotfiles
cp -r ~/.pi ~/dotfiles/pi

cd ~/dotfiles
git add --all
git commit
git push

