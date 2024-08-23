#!/bin/bash
sed -i 's/#Port\s22/Port 4272/' /etc/ssh/sshd_config
systemctl restart sshd
yum install -y docker
systemctl enable --now docker
usermod -aG docker ec2-user
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.0/2024-05-12/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
yum install -y https://dev.mysql.com/get/mysql84-community-release-el9-1.noarch.rpm
yum install -y mysql-server
systemctl enable --now mysqld
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh