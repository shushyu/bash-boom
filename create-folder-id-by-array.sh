#!/bin/bash

declare -A user_info  # Deklariere ein assoziatives Array

# LDAP-Suche und Fülle das Array
while IFS= read -r line; do
    if [[ "$line" == mail:* ]]; then
        email=$(echo "$line" | cut -d " " -f2)
        username=$(echo "$email" | cut -d "@" -f1)
        user_info[$username,email]="$email"
    elif [[ "$line" == displayName:* ]]; then
        name=$(echo "$line" | cut -d " " -f2-)
        # Wir nehmen an, dass der displayName nach der E-Mail kommt,
        # was bedeutet, dass $username bereits definiert wurde.
        user_info[$username,name]="$name"
    fi
done < <(ldapsearch -x -H "ldap://$AD_SERVER" -D "$AD_USER" -w "$AD_PASS" -b "$AD_SEARCH_BASE" "deinSuchfilter")

# Durchlaufe das Array und erstelle die Dateien
for username in "${!user_info[@]}"; do
    email=${user_info[$username,email]}
    name=${user_info[$username,name]}
    # Überprüfe, ob sowohl E-Mail als auch Name vorhanden sind
    if [[ -n "$email" && -n "$name" ]]; then
        mkdir -p "$username"
        identity_file="$username/identities"
        echo -n > "$identity_file" # Leere die Datei, falls sie bereits existiert
        # Befülle die Datei mit dem JSON-Inhalt
        echo "{" > "$identity_file"
        echo "  \"Id\":\"\",\"Label\":\"\",\"Email\":\"$email\",\"Name\":\"$name\",\"ReplyTo\":\"\",\"Bcc\":\"\",\"Signature\":\"\",\"SignatureInsertBefore\":false,\"SentFolder\":\"\",\"pgpEncrypt\":false,\"pgpSign\":false,\"smimeKey\":\"\",\"smimeCertificate\":\"\"" >> "$identity_file"
        echo "}" >> "$identity_file"
    else
        echo "Eintrag für $username übersprungen, da Informationen fehlen."
    fi
done
