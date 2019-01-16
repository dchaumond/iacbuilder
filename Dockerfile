# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM alpine:3.8

ARG KOPS_VERSION=1.10.0
ARG TERRAFORM_VERSION=0.11.8
# KUBECTL_SOURCE: Change to kubernetes-dev/ci for CI
ARG KUBECTL_SOURCE=kubernetes-release/release
# KUBECTL_TRACK: Currently latest from KUBECTL_SOURCE. Change to latest-1.3.txt, etc. if desired.
ARG KUBECTL_TRACK=stable.txt

ARG KUBECTL_ARCH=linux/amd64

# Kops
RUN apk add --no-cache --update ca-certificates vim curl jq && \
    KOPS_URL=$(curl -s https://api.github.com/repos/kubernetes/kops/releases | jq -r ".[] | select(.name == env.KOPS_VERSION) | .assets[] | select(.name == \"kops-linux-amd64\") | .browser_download_url") && \
    curl -SsL --retry 5 "${KOPS_URL}" > /usr/local/bin/kops && \
    chmod +x /usr/local/bin/kops && \
    KUBECTL_VERSION=$(curl -SsL --retry 5 "https://storage.googleapis.com/${KUBECTL_SOURCE}/${KUBECTL_TRACK}") && \
    curl -SsL --retry 5 "https://storage.googleapis.com/${KUBECTL_SOURCE}/${KUBECTL_VERSION}/bin/${KUBECTL_ARCH}/kubectl" > /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Terraform
RUN apk add make python bash ca-certificates openssl unzip wget && \
    cd /tmp && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/ && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf /var/tmp/*

# AWS cli + Jinja2 (python)
RUN python -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip install --upgrade pip setuptools && \
    pip install jinja2 jinja2-time json2yaml && \
    pip install --upgrade awscli && \
    rm -r /root/.cache

ENTRYPOINT ["/bin/bash"]