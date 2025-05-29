#!/usr/bin/env bash

read -sp "Encrypt Password: " PASSWORD
echo

for file in unlocked/*; do
    OUTPUT="locked/$(basename $file)"
    echo "Encrypting File: $file -> $OUTPUT"
    echo "$PASSWORD" | openssl enc -aes-256-cbc -salt -pbkdf2 -in $file -out "locked/$(basename $file)" -pass stdin
done
