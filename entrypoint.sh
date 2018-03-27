#!/bin/sh

[ -z "${DOMAIN}" ] && echo "Missing DOMAIN env variable!"
[ -z "${DOMAIN}" ] && exit 1
[ -z "${UPSTREAM}" ] && UPSTREAM="upstream:3000"

echo "Working for DOMAIN=${DOMAIN} and UPSTREAM=${UPSTREAM}"

mkdir -p /etc/nginx/certs

if [ ! -f /certs/dhparams.pem ]; then
    echo "# No backup dhparams. generating one"
    openssl dhparam -out /certs/dhparams.pem 2048
fi
cp -v /certs/dhparams.pem /etc/nginx/certs


if [ -d "/root/.acme.sh" ]; then
    echo "# Acme.sh dir found"
else
    echo "# Acme.sh dir NOT found!"
    exit 1
fi

if [ -d "/certs/${DOMAIN}" ]; then
    echo "# Backup certs found"
    cp -vr "/certs/${DOMAIN}" /root/.acme.sh
else
    echo "# No backup certs found issuing a new one"
    "/root/.acme.sh"/acme.sh --issue -d ${DOMAIN} --standalone -d ${DOMAIN}
    echo "# Creating a backup"
    cp -vr "/root/.acme.sh/${DOMAIN}" /certs
fi

echo "# Check and renew certificates"
"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh"

echo "# Copy certificates to nginx"
"/root/.acme.sh"/acme.sh --install-cert -d ${DOMAIN} --key-file /etc/nginx/certs/privkey.pem --fullchain-file /etc/nginx/certs/fullchain.pem


if [ -f "/etc/nginx/conf.d/default.conf" ]; then
    echo "Rendering default.conf for DOMAIN=${DOMAIN} and UPSTREAM=${UPSTREAM}"
    sed -e "s/\${DOMAIN}/${DOMAIN}/g" -e "s/\${UPSTREAM}/${UPSTREAM}/" /etc/nginx/conf.d/default.conf
fi

# Check for the gcsfuse binary
if which gcsfuse
then
  echo "# Found a gcsfuse binary"
  if [ "${BUCKET}" != "" ]; then
    echo "# Mounting the '$BUCKET' bucket on /mnt:"
    which gcsfuse && gcsfuse -o allow_other --implicit-dirs "$BUCKET" /mnt
  fi
fi

# Launch nginx in the foreground
/usr/sbin/nginx -g "daemon off;"
