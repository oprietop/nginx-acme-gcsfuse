# nginx-acme-gcsfuse
alpine:linux with automated let's encrypt and gcsmount

## Example  
```bash
docker run --detach \
  --link backend:backend \
  --env DOMAIN=foo.bar \
  --env UPSTREAM=backend:8080 \
  --env BUCKET=mybucket \
  --publish 80:80 \
  --publish 443:443 \
  oprietop\nginx-acme-gcsfuse
```

## Notes  
 * The only requirement is a working DNS for the host
 * Mount /certs outside the container to serialize the certificates (recommended) 
 * You can tune and mount nginx.conf and/or default.conf for more elaborated setups  
 * The bucket is optional
 * Look at the dockerfile for another example

## Thanks!
https://github.com/nginxinc/docker-nginx  
https://github.com/smashwilson/lets-nginx  
https://github.com/Neilpang/acme.sh/issues  
