#!/bin/bash
yum install -y jq curl git docker --allowerasing
systemctl enable --now docker
usermod -aG docker ec2-user