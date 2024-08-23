#!/bin/bash
sed -i 's/#Port\s22/Port 2220/' /etc/ssh/sshd_config
aws iam create-login-profile --user-name wsi-project-user --password Password01!
systemctl restart sshd