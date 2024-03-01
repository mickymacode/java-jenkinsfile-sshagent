#!/usr/bin/env bash

#这里export一个新的变量出去，叫image，值是刚刚从jenkinsfile里，bash ./server-cmds.sh ${IMAGE_NAME} 传过来的参数
#这个export的变量，给到docker-compos.yaml
export IMAGE=$1
docker-compose -f docker-compose.yaml up --detach
echo "success"
