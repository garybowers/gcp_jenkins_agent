FROM debian:stretch

ARG GCLOUD_SDK_VERSION=238.0.0
ARG TERRAFORM_VERSION=0.11.13
ARG VAULT_VERSION=1.0.1
ARG GSUITE_TERRAFORM_VERSION=0.1.10

### Setup Debian
RUN apt-get -qqy update && apt-get install -qqy \
        curl \
        wget \
        python-dev \
        python-setuptools \
        apt-transport-https \
        lsb-release \
        openssh-client \
        git \
        gnupg \
        ca-certificates \
        sudo \
        unzip \
        make \
        && easy_install -U pip && \
        pip install -U crcmod

### GCLOUD SDK
ENV GCLOUD_SDK_VERSION=$GCLOUD_SDK_VERSION
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && \
    apt-get install -y google-cloud-sdk=${GCLOUD_SDK_VERSION}-0 \
        kubectl && \
        gcloud config set core/disable_usage_reporting true && \
        gcloud config set component_manager/disable_update_check true && \
        gcloud config set metrics/environment github_docker_image

### Terraform
ENV TERRAFORM_VERSION=$TERRAFORM_VERSION
ENV TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
RUN echo ${TERRAFORM_URL} && \
    curl -fSL "${TERRAFORM_URL}" -o /bin/terraform.zip && \
    unzip /bin/terraform.zip -d /bin


### VAULT
ENV VAULT_URL=https://releases.hashicorp.com/vault/$VAULT_VERSION/vault_${VAULT_VERSION}_linux_amd64.zip
RUN curl -fSL "{$VAULT_URL}" -o /bin/vault.zip && \
    unzip /bin/vault.zip -d /bin && \
    rm -f /bin/vault.zip

### GSUITE
ENV GSUITE_TERRAFORM_VERSION=$GSUITE_TERRAFORM_VERSION
ENV GSUITE_URL=https://github.com/DeviaVir/terraform-provider-gsuite/releases/download/v${GSUITE_TERRAFORM_VERSION}/terraform-provider-gsuite_${GSUITE_TERRAFORM_VERSION}_linux_amd64.tgz
RUN curl -fSL ${GSUITE_URL} -o /tmp/terraform-provider-gsuite_${GSUITE_TERRAFORM_VERSION}_linux_amd64.tgz && \
    mkdir -p ${HOME}/.terraform.d/plugins/linux_amd64 && \
    tar -xvzf /tmp/terraform-provider-gsuite_${GSUITE_TERRAFORM_VERSION}_linux_amd64.tgz -C ${HOME}/.terraform.d/plugins/linux_amd64
