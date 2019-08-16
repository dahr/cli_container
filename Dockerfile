FROM golang:alpine
MAINTAINER "Dave Ahr <dahr@vmware.com>"

# Install libraries
RUN echo "Installing Libraries" \
    && apk add --update git bash openssh python3 curl findutils jq wget bash-completion openssh-server
RUN echo "Installing Ansible Libs" \
    && apk add --update sudo python py-pip openssl ca-certificates \
    && apk add --update --virtual build-dependencies python-dev libffi-dev openssl-dev build-base
RUN echo "Installing AWS Libs" \
    && apk add --update groff less \
    && rm -rf /tmp/* /var/cache/apk/*

ENV TERRAFORM_VERSION=0.12.6
ENV PACKER_VERSION=1.4.3
ENV KUBECTL_VERSION=v1.14.5
ENV BOSH_VERSION=6.0.0
WORKDIR /

# Install Terraform
RUN echo "Installing Terraform" \
  && wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && mv terraform /usr/local/bin/terraform \
  && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && terraform version

# Install Packer
RUN echo "Installing Packer" \
  && wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
  && unzip packer_${PACKER_VERSION}_linux_amd64.zip \
  && mv packer /usr/local/bin/packer \
  && rm packer_${PACKER_VERSION}_linux_amd64.zip \
  && packer version

# Install Ansible
RUN echo "Installing Ansible" \
    && pip install --upgrade pip cffi \
    && pip install ansible

# Install AWS CLI
RUN echo "Installing AWS CLI" \
    && pip install --upgrade awscli

# Install VKE
RUN echo "Installing VKE" \
  && wget -q https://s3.amazonaws.com/vke-cli-us-east-1/latest/linux64/vke \
  && chmod +x ./vke \
  && mv ./vke /usr/local/bin \
  && which vke \
  && vke --version

# Install Kubectl
RUN echo "Installing Kubectl" \
  && wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
  && chmod +x ./kubectl \
  && mv kubectl /usr/local/bin/kubectl \
  && which kubectl \
  && mkdir -p /etc/bash_completion.d \
  && kubectl completion bash > /etc/bash_completion.d/kubectl \
  && kubectl version --short --client

# Install Istio
RUN echo "Installing Istioctl" \
  && wget -q https://s3-us-west-2.amazonaws.com/nsxsm/istio/linux/istioctl \
  && chmod +x ./istioctl \
  && mv istioctl /usr/local/bin/istioctl \
  && which istioctl \
  && istioctl version

# Install Helm
RUN echo "Installing Helm" \
  && curl -o get_helm.sh https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get \
  && chmod +x ./get_helm.sh \
  && ./get_helm.sh \
  && rm ./get_helm.sh

# Install PKS CLI
RUN echo "Installing PKS CLI" \
  && wget -q --no-check-certificate "https://www.dropbox.com/s/t3jk7sf426ifj5a/pks-linux-amd64-1.4.0-build.230" \
  && mv pks-linux-amd64-1.4.0-build.230 /usr/local/bin/pks \
  && chmod +x ./usr/local/bin/pks \
  && which pks \
  && pks --version

# Install Cloud Foundry Bosh CLI
RUN echo "Installing Bosh CLI" \
  && wget -q https://github.com/cloudfoundry/bosh-cli/releases/download/v${BOSH_VERSION}/bosh-cli-${BOSH_VERSION}-linux-amd64 \
  && mv bosh-cli-${BOSH_VERSION}-linux-amd64 /usr/local/bin/bosh \
  && chmod +x ./usr/local/bin/bosh \
  && which bosh \
  && bosh --version

# Install Cloud Foundry UAAC
RUN echo "Installing uaac" \
  && apk add ruby ruby-dev ruby-rdoc \
  && gem install cf-uaac \
  && which uaac \
  && uaac --version
  
# Install Azure CLI
COPY azure-cli /root/azure-cli
RUN echo "Installing Azure CLI (az)" \
  && python /root/azure-cli/install.py \
  && which az \
  && az --version

# Create Aliases
RUN echo "alias k=kubectl" > /root/.profile

# Copy support files
COPY bosh /root/bosh