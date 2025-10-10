#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

alias home="cd ~/"
alias downloads="cd ~/Downloads/"
alias documents="cd ~/Documents/"
alias desktop="cd ~/Desktop/"
alias www="cd /var/www/html/"
alias c="clear"
alias reload="sudo systemctl restart apache2.service mysql phpsessionclean.service"