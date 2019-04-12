FROM alpine:3.9.3

ENV HELM_VERSION v2.13.1
ENV HELM_DIFF_VERSION v2.11.0+3
ENV HELM_SECRET_VERSION v1.3.1
ENV HELMFILE_VERSION v0.54.0
ENV AWS_IAM_AUTH_VERSION 1.12.7/2019-03-27
ENV VAULT_VERSION 1.0.1
ENV AWS_CLI_VERSION 1.16.140

RUN apk --no-cache add curl bash make openssh jq ca-certificates git gettext groff less \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-git-crypt/master/sgerrand.rsa.pub \
    && wget https://github.com/sgerrand/alpine-pkg-git-crypt/releases/download/0.6.0-r1/git-crypt-0.6.0-r1.apk \
    && apk add git-crypt-0.6.0-r1.apk \
    && rm git-crypt-0.6.0-r1.apk

RUN curl -sLo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl

ENV HELM_HOME /helm
RUN curl -sLo /tmp/helm.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz \
 && tar -zxf /tmp/helm.tar.gz -C /tmp/ \
 && cp /tmp/linux-amd64/helm /usr/local/bin/ \
 && rm -rf /tmp/linux-amd64/ /tmp/helm.tar.gz

RUN curl -sLo /usr/local/bin/helmfile https://github.com/roboll/helmfile/releases/download/v0.54.0/helmfile_linux_amd64

RUN mkdir -p "$(helm home)/plugins" \
 && helm plugin install https://github.com/databus23/helm-diff --version="${HELM_DIFF_VERSION}" \
 && helm plugin install https://github.com/futuresimple/helm-secrets --version="${HELM_SECRET_VERSION}" \
 && rm -rf /tmp/helm-diff /tmp/helm-diff.tgz

RUN wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
 && unzip -d /bin vault_${VAULT_VERSION}_linux_amd64.zip \
 && rm vault_${VAULT_VERSION}_linux_amd64.zip

RUN curl -o /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/${AWS_IAM_AUTH_VERSION}/bin/linux/amd64/aws-iam-authenticator \
 && chmod +x /usr/local/bin/aws-iam-authenticator

RUN apk -v --update add \
        python3 \
        && \
        pip3 install --upgrade pip && \
        pip3 install awscli==${AWS_CLI_VERSION} --upgrade && \
        rm /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
