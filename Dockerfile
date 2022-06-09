FROM redfactorlabs/concourse-smuggler-resource:alpine 
FROM alpine:3.14

COPY --from=0 /opt/resource/smuggler /opt/resource/smuggler

COPY --from=0 /opt/resource/smuggler.yml /opt/resource/smuggler.yml

RUN ln /opt/resource/smuggler /opt/resource/check \
    && ln /opt/resource/smuggler /opt/resource/in \
    && ln /opt/resource/smuggler /opt/resource/out

ENV PACKAGES "curl openssl ca-certificates jq python3 py-pip"
RUN apk add --update $PACKAGES && rm -rf /var/cache/apk/*

COPY assets/ /opt/resource/

RUN pip install -r /opt/resource/requirements.txt

RUN chmod +x /opt/resource/*
