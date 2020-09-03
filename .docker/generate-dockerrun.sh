#!/usr/bin/env bash

APPLICATION=$1
VERSION=$2
PHASE=$3

SVC_PORT=8080

SCRIPT_PATH=$(cd ${0%/*}; echo $PWD)

cat <<EOF > $SCRIPT_PATH/Dockerrun.aws.json
{
  "AWSEBDockerrunVersion": 2,
  "volumes": [
    {
      "name": "app-envs",
      "host": {
        "sourcePath": "/var/app/envs"
      }
    }
  ],
  "containerDefinitions": [
    {
      "name": "app",
      "image": "ECR_REGISTRY_URL/${APPLICATION}:${VERSION}",
      "environment": [
        {
          "name": "Container",
          "value": "Node.js"
        }
      ],
      "essential": true,
      "memory": 128,
      "portMappings": [
        {
          "hostPort": ${SVC_PORT},
          "containerPort": ${SVC_PORT}
        }
      ],
      "mountPoints": [
        {
          "sourceVolume": "app-envs",
          "containerPath": "/var/app/envs"
        },
        {
          "sourceVolume": "awseb-logs-app",
          "containerPath": "/root/app/log"
        }
      ]
    },
    {
      "name": "nginx",
      "image": "ECR_REGISTRY_URL/${APPLICATION}-nginx:${VERSION}",
      "essential": true,
      "memory": 128,
      "portMappings": [
        {
          "hostPort": 80,
          "containerPort": 80
        }
      ],
      "links": [
        "app"
      ],
      "mountPoints": [
        {
          "sourceVolume": "awseb-logs-nginx",
          "containerPath": "/var/log/nginx"
        }
      ]
    }
  ]
}
EOF
