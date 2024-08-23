#!/bin/bash

dnf install docker

systemctl restart docker
systemctl enable docker