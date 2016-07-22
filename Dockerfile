FROM alpine:3.3

ENV PACKAGES "curl openssl ca-certificates jq"

RUN apk add --update $PACKAGES && rm -rf /var/cache/apk/*

COPY assets/ /opt/resource/
RUN chmod +x /opt/resource/*
