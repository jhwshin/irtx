#!/usr/bin/env bash

read -sp "Decrypt Password: " PASSWORD
echo

mkdir -p unlocked

for file in locked/*; do
    OUTPUT="unlocked/$(basename $file)"
    echo "$PASSWORD" | openssl enc -d -aes-256-cbc -salt -pbkdf2 -in $file -out "${OUTPUT}.tmp" -pass stdin 2>/dev/null
    status=$?

    if [[ $status -eq 0 ]]; then
        echo "Decrypting File: $file -> $OUTPUT"
        mv "${OUTPUT}.tmp" "${OUTPUT}"
	chmod +x "${OUTPUT}"
    else
        echo "Decrypting ${OUTPUT} Failed."
        rm -f "${OUTPUT}.tmp"
    fi
done
