FROM nginx:alpine
MAINTAINER Oscar Prieto <oprietop@uoc.edu>

# Add the entrypoint and template files
COPY entrypoint.sh /opt/entrypoint.sh
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# Single layer RUN
RUN apk add --update --no-cache openssl curl tzdata socat fuse \
    && curl https://get.acme.sh | sh \
    && apk add --no-cache --virtual .build-dependencies git build-base go \
    && go get -v -u github.com/googlecloudplatform/gcsfuse \
    && mv /root/go/bin/gcsfuse /usr/local/bin \
    && apk del .build-dependencies \
    && rm -rf /var/cache/apk/* /root/go \
    && chmod +x /opt/entrypoint.sh \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Set the entrypoint
ENTRYPOINT ["/opt/entrypoint.sh"]
