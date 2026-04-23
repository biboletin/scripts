#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

alias home="cd ~/"
alias downloads="cd ~/Downloads/"
alias documents="cd ~/Documents/"
alias desktop="cd ~/Desktop/"
alias www="cd /var/www/html/"
alias c="clear"
alias reload="sudo systemctl restart apache2.service mysql phpsessionclean.service php8.4-fpm.service && php -r 'opcache_reset();'"
alias update="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y && sudo journalctl --vacuum-time=7d"