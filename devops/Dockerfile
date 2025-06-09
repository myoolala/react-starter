FROM golang

# Update our image
RUN <<EOF
    echo "Updating base container"
    apt-get -y update
    apt-get -y install zip python3 python3-pip vim jq lsb-release software-properties-common
    apt-get -y upgrade
    pip install awscli --break-system-packages
    apt-get clean all
    echo "Installing node version manager"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    echo "Installing tenv"
    DKPG_VERSION=$(dpkg --print-architecture)
    LATEST_VERSION=$(curl --silent https://api.github.com/repos/tofuutils/tenv/releases/latest | jq -r .tag_name)
    curl -O -L "https://github.com/tofuutils/tenv/releases/latest/download/tenv_${LATEST_VERSION}_${DKPG_VERSION}.deb"
    dpkg -i "tenv_${LATEST_VERSION}_${DKPG_VERSION}.deb"
    echo "Installing SOPS"
    go install github.com/getsops/sops/v3/cmd/sops@v3.8.1
    echo "Installing packer"
    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
    apt-get update && apt-get install -y packer
EOF

RUN <<EOF
    tenv tofu install 1.7.1
    tenv tofu use 1.7.1
    tenv terragrunt install 0.77.11
    bash -c "source ~/.bashrc && nvm install 20"
    echo 'alias tf="tofu"' >> ~/.bashrc
    echo 'alias tfi="tofu init"' >> ~/.bashrc
    echo 'alias tfp="tofu plan"' >> ~/.bashrc
    echo 'alias tfa="tofu apply"' >> ~/.bashrc
    echo 'alias tfd="tofu destroy"' >> ~/.bashrc
    echo 'alias tg="terragrunt"' >> ~/.bashrc
    echo 'alias tgi="terragrunt init"' >> ~/.bashrc
    echo 'alias tgp="terragrunt plan"' >> ~/.bashrc
    echo 'alias tga="terragrunt apply"' >> ~/.bashrc
    echo 'alias tgd="terragrunt destroy"' >> ~/.bashrc
EOF

WORKDIR /root/repo