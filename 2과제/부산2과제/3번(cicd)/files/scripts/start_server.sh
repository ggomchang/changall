#!/bin/bash

aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin 702661606257.dkr.ecr.ap-northeast-2.amazonaws.com
sudo docker stop codedeploy
sudo docker rm codedeploy
sudo docker rmi 702661606257.dkr.ecr.ap-northeast-2.amazonaws.com/wsi-ecr
sudo docker pull 702661606257.dkr.ecr.ap-northeast-2.amazonaws.com/wsi-ecr:latest
sudo docker run -d --name codedeploy -p 80:8080 702661606257.dkr.ecr.ap-northeast-2.amazonaws.com/wsi-ecr:latest