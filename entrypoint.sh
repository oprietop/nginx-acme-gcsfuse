#!/bin/sh

[ -z "${DOMAIN}" ] && echo "Missing DOMAIN env variable!"
[ -z "${DOMAIN}" ] && exit 1
[ -z "${UPSTREAM}" ] && UPSTREAM="upstream:3000"
[ -z "${HTPASSWD}" ] && HTPASSWD='admin:admin'

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

echo "# Print certificates"
"/root/.acme.sh"/acme.sh --list

echo "# Renew all certificates if needed"
"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh"

echo "# Copy certificates to nginx"
"/root/.acme.sh"/acme.sh --install-cert -d ${DOMAIN} --key-file /etc/nginx/certs/privkey.pem --fullchain-file /etc/nginx/certs/fullchain.pem

#echo "# Create a crontab to maintain the cert updated"
#echo '"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" && nginx -s reload' > /etc/cron.daily/renew.sh
#chmod +x /etc/cron.daily/renew.sh

if [ -f "/etc/nginx/conf.d/default.conf" ]; then
    echo "# Rendering default.conf for DOMAIN=${DOMAIN} and UPSTREAM=${UPSTREAM}"
    sed -i'' "s@\${DOMAIN}@${DOMAIN}@g" /etc/nginx/conf.d/default.conf
    sed -i'' "s@\${UPSTREAM}@${UPSTREAM}@" /etc/nginx/conf.d/default.conf
fi

if which gcsfuse
then
  echo "# Found a gcsfuse binary"
  if [ "${BUCKET}" != "" ]; then
    echo "# Mounting the '$BUCKET' bucket on /mnt:"
    which gcsfuse && gcsfuse -o allow_other --implicit-dirs "$BUCKET" /mnt
  fi
fi

USER=`echo $HTPASSWD | cut -d: -f1`
PASS=`echo $HTPASSWD | cut -d: -f2`
ENCPASS=`openssl passwd -apr1 $PASS`
echo "# USER: ${USER} PASS: ${PASS} ENCPASS: ${ENCPASS}"
HTPASSWD="${USER}:${ENCPASS}"
echo "# Using '$HTPASSWD' in /etc/nginx/htpasswd"
echo "$HTPASSWD" > /etc/nginx/htpasswd

# Create a nginx owned wevdab directory
mkdir -p /usr/share/nginx/webdav
chown nginx:nginx /usr/share/nginx/webdav

echo "# Launch nginx in the foreground"
/usr/sbin/nginx -g "daemon off;"
