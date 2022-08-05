FROM golang

# Update our image
RUN echo "Updating base container" && \
    apt-get -y update && \
    apt-get -y install zip && \
    apt-get -y upgrade && \
    apt-get clean && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash && \
    echo "Installing tfenv" && \
    git clone https://github.com/tfutils/tfenv.git ~/.tfenv && \
    ln -s ~/.tfenv/bin/* /usr/local/bin && \
    echo "Installing tgenv" && \
    git clone https://github.com/cunymatthieu/tgenv.git ~/.tgenv && \
    ln -s ~/.tgenv/bin/* /usr/local/bin && \
    echo "Installing SOPS" && \
    go install go.mozilla.org/sops/v3/cmd/sops@v3.7.1

RUN tfenv install v1.1.2 && \
    tfenv use 1.1.2 && \
    tgenv install 0.35.16 && \
    bash -c "source ~/.bashrc && nvm install 17"

WORKDIR /root/repo