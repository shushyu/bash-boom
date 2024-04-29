#!/bin/bash

declare -A user_info  


while IFS= read -r line; do
    if [[ "$line" == mail:* ]]; then
        email=$(echo "$line" | cut -d " " -f2)
    elif [[ "$line" == displayName:* ]]; then
        username=$(echo "$line" | cut -d " " -f2-)
        user_info[$email]=$username
    fi
done < <(ldapsearch)

for mail in "${!user_info[@]}"; do
    
    uid = $(echo "$mail" | cut -d "@" -f1)
    echo "UID: $uid"
    name = ${user_info[mail]}
    echo "NAME: $name"
    echo "MAIL: $mail"

    # if [[ -n "$email" && -n "$name" ]]; then
    #     mkdir -p "$uid"
    #     identity_file="$uid/identities"
    #     echo -n > "$identity_file" # Leere die Datei, falls sie bereits existiert
    #     # Befülle die Datei mit dem JSON-Inhalt
    #     echo "{\"---\":{" > "$identity_file"
    #     echo " \"Id\":\"\",\"Label\":\"\",\"Email\":\"$email\",\"Name\":\"$name\",\"ReplyTo\":\"\",\"Bcc\":\"\",\"Signature\":\"\",\"SignatureInsertBefore\":false,\"SentFolder\":\"\",\"pgpEncrypt\":false,\"pgpSign\":false,\"smimeKey\":\"\",\"smimeCertificate\":\"\"" >> "$identity_file"
    #     echo "}}" >> "$identity_file"
    # else
    #     echo "Eintrag für $username übersprungen, da Informationen fehlen."
    # fi
done
