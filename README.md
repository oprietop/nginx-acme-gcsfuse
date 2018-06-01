# nginx-acme-gcsfuse
alpine:linux with automated let's encrypt and gcsmount

The images is made with some concrete purposes:  
 * Preconfigured nginx  
 * easy hardened tls  
 * only one upstream url  
 * configurable GCS mountpoint via bucket name, intended for usage in kubernetes clusters  
 * configurable https access 

## Example  
```bash
docker run --detach \
  --link backend:backend \
  --env DOMAIN=foo.bar \
  --env UPSTREAM=backend:8080 \
  --env BUCKET=mybucket \
  --env HTPASSWD=admin:admin \
  --publish 80:80 \
  --publish 443:443 \
  oprietop\nginx-acme-gcsfuse
```

## Notes  
 * The only requirement is a working DNS for the host  
 * Mount /certs outside the container to serialize the certificates (recommended) 
 * The bucket is optional at it will be mounted in foo.bar/mnt by default  
 * Look at the dockerfile for another example using grafana
 * Only one UPSTREAM url to Proxy Pass, the image is intended for a simple use case  
 * You can tune and mount nginx.conf and/or default.conf for more elaborated setups  

## Links
https://github.com/nginxinc/docker-nginx  
https://github.com/smashwilson/lets-nginx  
https://github.com/Neilpang/acme.sh/issues  
