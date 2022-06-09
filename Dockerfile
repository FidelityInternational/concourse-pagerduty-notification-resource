FROM redfactorlabs/concourse-smuggler-resource:alpine 
FROM alpine:3.14

ENV PACKAGES "curl openssl ca-certificates jq python3 py-pip"
RUN apk add --update $PACKAGES && rm -rf /var/cache/apk/*

COPY assets/ /opt/resource/

RUN pip install -r /opt/resource/requirements.txt

RUN chmod +x /opt/resource/*
