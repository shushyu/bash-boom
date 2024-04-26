#!/bin/bash

# Verbindungseinstellungen für das AD - diese müssen angepasst werden
AD_SERVER="dein.ad.server"
AD_SEARCH_BASE="dc=deine,dc=domäne"
AD_USER="deinADBenutzername"
AD_PASS="deinADPasswort"

ldapsearch -x -H ldaps://$AD_SERVER -D $AD_USER -w $AD_PASS -b $AD_SEARCH_BASE '(objectClass=organizationalPerson)' mail displayName | while read line

do
    if [[ "$line" == mail:* ]]; then
        EMAIL=$(echo "$line" | cut -d " " -f2)
        USERNAME=$(echo "$EMAIL" | cut -d "@" -f1)
        mkdir -p "$USERNAME"
        IDENTITY_FILE="$USERNAME/identities"
        echo -n > "$IDENTITY_FILE" 
    elif [[ "$line" == displayName:* ]]; then
        NAME=$(echo "$line" | cut -d " " -f2-)
        echo "{\"---\":" > "$IDENTITY_FILE"
        echo "  \"Id\":\"\"," >> "$IDENTITY_FILE"
        echo "  \"Label\":\"\"," >> "$IDENTITY_FILE"
        echo "  \"Email\":\"$EMAIL\"," >> "$IDENTITY_FILE"
        echo "  \"Name\":\"$NAME\"," >> "$IDENTITY_FILE"
        echo "  \"ReplyTo\":\"\"," >> "$IDENTITY_FILE"
        echo "  \"Bcc\":\"\"," >> "$IDENTITY_FILE"
        echo "  \"Signature\":\"\"," >> "$IDENTITY_FILE"
        echo "  \"SignatureInsertBefore\":false," >> "$IDENTITY_FILE"
        echo "  \"SentFolder\":\"\"," >> "$IDENTITY_FILE"
        echo "  \"pgpEncrypt\":false," >> "$IDENTITY_FILE"
        echo "  \"pgpSign\":false," >> "$IDENTITY_FILE"
        echo "  \"smimeKey\":\"\"," >> "$IDENTITY_FILE"
        echo "  \"smimeCertificate\":\"\"" >> "$IDENTITY_FILE"
        echo "}" >> "$IDENTITY_FILE"
    fi
done
