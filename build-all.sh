#!/bin/bash

IMG_DIR=img-scripts
SERVICES=(
    "dokuwiki"
    "gerrit"
    "jenkins"
    "nexus"
    "nginx"
    "openldap"
    "redmine"
)

for service in ${SERVICES[@]}; do
    (docker rmi ci/$service > /dev/null 2>&1) || echo "No old ci/$service image found for removal"
    if [[ -f $IMG_DIR/$service-docker/Dockerfile ]]; then
        echo "Building ci/${service}..."
        docker build --quiet -t ci/$service $IMG_DIR/$service-docker/ >> /dev/null
    else
        echo "No Dockerfile found for ${service}"
    fi
done

echo "Finished building all images"
