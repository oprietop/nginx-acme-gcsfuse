# nginx-acme-gcsfuse
alpine:linux with automated let's encrypt and gcsmount

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
