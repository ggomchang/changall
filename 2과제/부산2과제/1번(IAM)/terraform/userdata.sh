#!/bin/bash
yum install -y git
aws iam create-login-profile --user-name wsi-project-user1 --password Password01!
aws iam create-login-profile --user-name wsi-project-user2 --password Password01!