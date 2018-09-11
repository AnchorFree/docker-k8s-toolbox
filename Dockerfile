FROM alpine
RUN apk add --update curl

RUN apk --no-cache add ca-certificates git \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-git-crypt/master/sgerrand.rsa.pub \
    && wget https://github.com/sgerrand/alpine-pkg-git-crypt/releases/download/0.6.0-r0/git-crypt-0.6.0-r0.apk \
    && apk add git-crypt-0.6.0-r0.apk \
    && rm git-crypt-0.6.0-r0.apk \
    && apk add --update make openssh jq

RUN curl -sLo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl

ENV HELM_VERSION v2.10.0
RUN curl -sLo /tmp/helm.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz \
 && tar -zxf /tmp/helm.tar.gz -C /tmp/ \
 && cp /tmp/linux-amd64/helm /usr/local/bin/ \
 && rm -rf /tmp/linux-amd64/ /tmp/helm.tar.gz

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
