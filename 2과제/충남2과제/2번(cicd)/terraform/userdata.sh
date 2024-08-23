#!/bin/bash
yum install git -y
yum install docker -y
systemctl enable --now docker
usermod -aG docker ec2-user