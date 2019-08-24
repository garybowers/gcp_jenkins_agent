FROM debian:stretch-slim

ARG GCLOUD_SDK_VERSION=259.0.0
ARG TERRAFORM_VERSION=0.12.7
ARG VAULT_VERSION=1.0.3
ARG GSUITE_TERRAFORM_VERSION=0.1.23
ARG HELM_VERSION=2.14.3
ARG ANSIBLE_VERSION=2.2.1.0-2+deb9u1
ARG AWSCLI_VERSION=1.16.182
ARG AZURECLI_VERSION=2.0.66
ARG PACKER_VERSION=1.4.1
ARG INSPEC_VERSION=4.11.3

### Setup Debian
RUN apt-get -qqy update && apt-get install -qqy \
        apt-utils \
        curl \
        wget \
        python-dev \
        python-setuptools \
        python-pip \
        apt-transport-https \
        lsb-release \
        openssh-client \
        openssh-server \
        git \
        gnupg \
        ca-certificates \
        sudo \
        unzip \
        make

RUN pip install --upgrade crcmod

### Config user
RUN groupadd -r gcpdev && useradd -r -g gcpdev gcpdev

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
    mkdir -p /.terraform.d/plugins/linux_amd64 && \
    tar -xvzf /tmp/terraform-provider-gsuite_${GSUITE_TERRAFORM_VERSION}_linux_amd64.tgz -C /.terraform.d/plugins/linux_amd64

### HELM
ENV HELM_VERSION=$HELM_VERSION
ENV HELM_HOME=/.helm
ENV HELM_URL=https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz
RUN curl -fSL ${HELM_URL} -o /tmp/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -xvzf /tmp/helm-v${HELM_VERSION}-linux-amd64.tar.gz -C /bin && \
    ln -s /bin/linux-amd64/helm /bin/helm && \
    ln -s /bin/linux-amd64/tiller /bin/tiller && \
    helm init --client-only && \
    chmod -R 777 /.helm

### Ansible
ENV ANSIBLE_VERSION=$ANSIBLE_VERSION
RUN sudo apt-get install -y ansible=${ANSIBLE_VERSION}

### Packer
ENV PACKER_VERSION=$PACKER_VERSION
ENV PACKER_URL="https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip"
RUN echo ${PACKER_URL} && \
    curl -fSL "${PACKER_URL}" -o /bin/packer.zip && \
    unzip /bin/packer.zip -d /bin

### AWS CLI
ENV AWSCLI_VERSION=$AWSCLI_VERSION
RUN pip install awscli==${AWSCLI_VERSION}

### AZURE CLI
ENV AZURECLI_VERSION=$AZURECLI_VERSION
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

### Powershell
RUN sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/microsoft.list' && \
    sudo apt-get update -y && \
    apt-get install -y --allow-unauthenticated powershell

### INSPEC
ENV HAB_LICENSE=accept
ENV CHEF_LICENSE=accept
ENV INSPEC_VERSION=$INSPEC_VERSION
RUN curl -fSL https://packages.chef.io/files/stable/inspec/${INSPEC_VERSION}/ubuntu/18.04/inspec_${INSPEC_VERSION}-1_amd64.deb -o inspec.deb
RUN ls && \
    dpkg -i inspec.deb
RUN sudo mkdir /.chef && chmod -R 777 /.chef
RUN sudo mkdir /.inspec && chmod -R 777 /.inspec
