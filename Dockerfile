FROM golang:1.10.1-alpine3.7 as helmfile
ENV HELMFILE_VERSION v0.45.3
RUN apk add --no-cache make git
RUN go get github.com/roboll/helmfile
WORKDIR /go/src/github.com/roboll/helmfile/
RUN git checkout ${HELMFILE_VERSION}
RUN make static-linux


FROM alpine:3.8

ENV HELM_VERSION v2.12.2
ENV HELM_DIFF_VERSION v2.11.0+3
ENV HELM_SECRET_VERSION v1.3.1
ENV AWS_IAM_AUTH_VERSION 1.11.5/2018-12-06
ENV VAULT_VERSION 0.10.1

RUN apk --no-cache add curl bash make openssh jq ca-certificates git \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-git-crypt/master/sgerrand.rsa.pub \
    && wget https://github.com/sgerrand/alpine-pkg-git-crypt/releases/download/0.6.0-r0/git-crypt-0.6.0-r0.apk \
    && apk add git-crypt-0.6.0-r0.apk \
    && rm git-crypt-0.6.0-r0.apk

RUN curl -sLo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl

ENV HELM_HOME /helm
RUN curl -sLo /tmp/helm.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz \
 && tar -zxf /tmp/helm.tar.gz -C /tmp/ \
 && cp /tmp/linux-amd64/helm /usr/local/bin/ \
 && rm -rf /tmp/linux-amd64/ /tmp/helm.tar.gz

RUN mkdir -p "$(helm home)/plugins" \
 && helm plugin install https://github.com/databus23/helm-diff --version="${HELM_DIFF_VERSION}" \
 && helm plugin install https://github.com/futuresimple/helm-secrets --version="${HELM_SECRET_VERSION}" \
 && rm -rf /tmp/helm-diff /tmp/helm-diff.tgz

COPY --from=helmfile /go/src/github.com/roboll/helmfile/dist/helmfile_linux_amd64 /usr/local/bin/helmfile

RUN wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
 && unzip -d /bin vault_${VAULT_VERSION}_linux_amd64.zip \
 && rm vault_${VAULT_VERSION}_linux_amd64.zip

RUN curl -o /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/${AWS_IAM_AUTH_VERSION}/bin/linux/amd64/aws-iam-authenticator \
 && chmod +x /usr/local/bin/aws-iam-authenticator

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
