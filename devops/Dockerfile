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
    echo "Installing tfenv"
    git clone https://github.com/tfutils/tfenv.git ~/.tfenv
    ln -s ~/.tfenv/bin/* /usr/local/bin
    echo "Installing tgenv"
    git clone https://github.com/cunymatthieu/tgenv.git ~/.tgenv
    ln -s ~/.tgenv/bin/* /usr/local/bin
    echo "Installing SOPS"
    go install go.mozilla.org/sops/v3/cmd/sops@v3.7.3
    echo "Installing packer"
    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
    apt-get update && apt-get install -y packer
EOF

RUN <<EOF
    tfenv install 1.7.5
    tfenv use 1.7.5
    tgenv install 0.77.11
    bash -c "source ~/.bashrc && nvm install 20"
    echo 'alias tf="terraform"' >> ~/.bashrc
    echo 'alias tfi="terraform init"' >> ~/.bashrc
    echo 'alias tfp="terraform plan"' >> ~/.bashrc
    echo 'alias tfa="terraform apply"' >> ~/.bashrc
    echo 'alias tfd="terraform destroy"' >> ~/.bashrc
    echo 'alias tg="terragrunt"' >> ~/.bashrc
    echo 'alias tgi="terragrunt init"' >> ~/.bashrc
    echo 'alias tgp="terragrunt plan"' >> ~/.bashrc
    echo 'alias tga="terragrunt apply"' >> ~/.bashrc
    echo 'alias tgd="terragrunt destroy"' >> ~/.bashrc
EOF

WORKDIR /root/repo