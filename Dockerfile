ARG IMAGE_REPOSITORY=quay.io/eduk8s

FROM registry.tanzu.vmware.com/tanzu-application-platform/tap-packages@sha256:a8870aa60b45495d298df5b65c69b3d7972608da4367bd6e69d6e392ac969dd4

# All the direct Downloads need to run as root as they are going to /usr/local/bin
USER root

# Pivnet CLI
RUN curl -L -o /usr/local/bin/pivnet https://github.com/pivotal-cf/pivnet-cli/releases/download/v3.0.1/pivnet-linux-amd64-3.0.1  && \
    chmod 755 /usr/local/bin/pivnet

# Tanzu CLI
COPY tanzu-framework-linux-amd64.tar /tmp
RUN export TANZU_CLI_NO_INIT=true
RUN cd /tmp && tar -xvf "tanzu-framework-linux-amd64.tar" -C /tmp && \ 
    sudo install "cli/core/v0.11.4/tanzu-core-linux_amd64" /usr/local/bin/tanzu && \ 
    tanzu plugin install --local cli all

RUN curl -L -o /usr/local/bin/kctrl https://github.com/vmware-tanzu/carvel-kapp-controller/releases/download/v0.36.1/kctrl-linux-amd64 && \
    chmod 755 /usr/local/bin/kctrl

# Utilities
RUN apt-get update && apt-get install -y unzip

# Install krew
RUN \
( \
  set -x; cd "$(mktemp -d)" && \
  OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
  KREW="krew-${OS}_${ARCH}" && \
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
  tar zxvf "${KREW}.tar.gz" && \
  ./"${KREW}" install krew \
)
RUN echo "export PATH=\"${KREW_ROOT:-$HOME/.krew}/bin:$PATH\"" >> ${HOME}/.bashrc
ENV PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
RUN kubectl krew install tree
RUN kubectl krew install view-secret
RUN kubectl krew install ctx
RUN kubectl krew install ns
RUN kubectl krew install konfig
RUN kubectl krew install eksporter
RUN kubectl krew install slice
RUN chmod 775 -R $HOME/.krew
RUN apt update
RUN apt install ruby-full -y

RUN rm -rf /tmp/*

USER 1001
COPY --chown=1001:0 . /home/eduk8s/
RUN fix-permissions /home/eduk8s
RUN rm /home/eduk8s/tanzu-framework-linux-amd64.tar
