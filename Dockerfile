FROM alpine:3.9.3

ENV HELM_VERSION v2.17.0
ENV HELM_DIFF_VERSION v3.5.0
ENV HELM_SECRET_VERSION v1.3.1
ENV HELM_V3_VERSION v3.7.2
ENV HELM_V3_SHA256 4ae30e48966aba5f807a4e140dad6736ee1a392940101e4d79ffb4ee86200a9e 
ENV HELMFILE_VERSION 0.144.0
ENV AWS_IAM_AUTH_VERSION 0.6.2
ENV VAULT_VERSION 1.3.1
ENV AWS_CLI_VERSION 1.16.276
ENV KUBECTL_VERSION v1.20.15

RUN apk --no-cache add curl bash make openssh jq ca-certificates git gettext groff less \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-git-crypt/master/sgerrand.rsa.pub \
    && wget https://github.com/sgerrand/alpine-pkg-git-crypt/releases/download/0.6.0-r1/git-crypt-0.6.0-r1.apk \
    && apk add git-crypt-0.6.0-r1.apk \
    && rm git-crypt-0.6.0-r1.apk

RUN curl -sLo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl

RUN curl -sLo /tmp/helm-v2.tar.gz https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz \
  && tar -zxf /tmp/helm-v2.tar.gz -C /tmp/ \
  && cp /tmp/linux-amd64/helm /usr/local/bin/helm2 \
  && rm -rf /tmp/linux-amd64/ /tmp/helm-v2.tar.gz

RUN curl -sLo /usr/local/bin/helmfile https://github.com/roboll/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_linux_amd64 \
 && chmod +x /usr/local/bin/helmfile

RUN wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
 && unzip -d /bin vault_${VAULT_VERSION}_linux_amd64.zip \
 && rm vault_${VAULT_VERSION}_linux_amd64.zip

RUN curl -sLo /tmp/helm-v3.tar.gz https://get.helm.sh/helm-${HELM_V3_VERSION}-linux-amd64.tar.gz \
 && echo "${HELM_V3_SHA256}  /tmp/helm-v3.tar.gz" | sha256sum -c - \
 && tar -zxf /tmp/helm-v3.tar.gz -C /tmp/ \
 && cp /tmp/linux-amd64/helm /usr/local/bin/helm \
 && rm -rf /tmp/linux-amd64/ /tmp/helm-v3.tar.gz

ENV HELM_HOME /helm

RUN mkdir -p "$(helm2 home)/plugins" \
 && helm plugin install https://github.com/databus23/helm-diff --version="${HELM_DIFF_VERSION}" \
 && helm2 plugin install https://github.com/databus23/helm-diff --version="${HELM_DIFF_VERSION}" \
 && helm plugin install https://github.com/futuresimple/helm-secrets --version="${HELM_SECRET_VERSION}" \
 && helm2 plugin install https://github.com/futuresimple/helm-secrets --version="${HELM_SECRET_VERSION}" \
 && rm -rf /tmp/helm-diff /tmp/helm-diff.tgz

RUN curl -L -o aws-iam-authenticator_${AWS_IAM_AUTH_VERSION}_linux_amd64 https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTH_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTH_VERSION}_linux_amd64 \
 && curl -L -o authenticator_checksums.txt https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTH_VERSION}/authenticator_${AWS_IAM_AUTH_VERSION}_checksums.txt \
 && cat authenticator_checksums.txt | grep aws-iam-authenticator_${AWS_IAM_AUTH_VERSION}_linux_amd64 > authenticator_checksums_new.txt \
 && sha256sum -c authenticator_checksums_new.txt \
 && rm -f authenticator_checksums.txt authenticator_checksums_new.txt \
 && mv aws-iam-authenticator_${AWS_IAM_AUTH_VERSION}_linux_amd64 /usr/local/bin/aws-iam-authenticator \
 && chmod +x /usr/local/bin/aws-iam-authenticator

RUN apk -v --update add \
        python3 \
        && \
        pip3 install --upgrade pip && \
        pip3 install awscli==${AWS_CLI_VERSION} --upgrade && \
        rm /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
