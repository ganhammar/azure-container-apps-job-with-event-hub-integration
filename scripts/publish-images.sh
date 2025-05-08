#!/bin/bash

docker_command=$DOCKER_COMMAND
github_org=$DOCKER_USERNAME
namespace_prefix='azure-container-apps-job-with-event-hub-integration'

$docker_command login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD ghcr.io

for image in processor; do
    $docker_command build -t $image -f src/$image/Dockerfile .
    $docker_command tag $image ghcr.io/${github_org}/${namespace_prefix}/${image}:latest
    $docker_command push ghcr.io/${github_org}/${namespace_prefix}/${image}:latest
done