#!/usr/bin/env bash

# update key
sudo wget https://archive.kali.org/archive-keyring.gpg -O /usr/share/keyrings/kali-archive-keyring.gpg

# update and upgrade
sudo apt update
