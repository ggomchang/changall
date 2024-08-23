#!/bin/bash
cd /home/ec2-user
yum install -y jq curl docker ruby wget --allowerasing
systemctl enable --now docker
usermod -aG docker ec2-user
wget https://aws-codedeploy-ap-northeast-2.s3.ap-northeast-2.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
systemctl start codedeploy-agent