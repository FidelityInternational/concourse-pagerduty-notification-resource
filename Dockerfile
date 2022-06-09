FROM redfactorlabs/concourse-smuggler-resource:alpine 
FROM alpine:3.14

COPY --from=0 /opt/resource/smuggler /opt/resource/smuggler

COPY assets/ /opt/resource/

RUN ln /opt/resource/smuggler /opt/resource/check \
    && ln /opt/resource/smuggler /opt/resource/in \
    && ln /opt/resource/smuggler /opt/resource/out

ENV PACKAGES "bash curl openssl ca-certificates jq python3 py-pip libssl-dev"
RUN apk add --update $PACKAGES && rm -rf /var/cache/apk/*

RUN pip install -r /opt/resource/requirements.txt

RUN chmod +x /opt/resource/*
