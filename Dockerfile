FROM debian:stretch

ARG GCLOUD_SDK_VERSION=258.0.0
ARG TERRAFORM_VERSION=0.11.14
ARG VAULT_VERSION=1.0.3
ARG GSUITE_TERRAFORM_VERSION=0.1.10
ARG HELM_VERSION=2.14.0

### Setup Debian
RUN apt-get -qqy update && apt-get install -qqy \
        apt-utils \
        curl \
        wget \
        python-dev \
        python-setuptools \
        apt-transport-https \
        lsb-release \
        openssh-client \
        openssh-server \
        git \
        gnupg \
        ca-certificates \
        sudo \
        unzip \
        make \
        golang \
        software-properties-common \
        && easy_install -U pip && \
        pip install -U crcmod

RUN sudo mkdir -p /.config/gcloud/configurations && \
    sudo mkdir -p /.gsutil && \
		sudo chmod -R 777 /.config/gcloud && \
    sudo chmod -R 777 /.gsutil

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


### INSPEC
ENV HAB_LICENSE=accept
ENV CHEF_LICENSE=accept
RUN curl -fSL https://packages.chef.io/files/stable/inspec/4.6.9/ubuntu/18.04/inspec_4.6.9-1_amd64.deb -o inspec.deb
RUN ls && \
    dpkg -i inspec.deb
RUN sudo mkdir /.chef && chmod -R 777 /.chef
RUN sudo mkdir /.inspec && chmod -R 777 /.inspec

### Docker CE
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - && \
    sudo add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/debian \
     $(lsb_release -cs) \
     stable"
RUN sudo apt-get update -y && sudo apt-get install -y docker-ce docker-ce-cli containerd.io
