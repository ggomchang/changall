#!/bin/bash

yum install docker -y
systemctl enable --now docker
usermod -aG docker ec2-user