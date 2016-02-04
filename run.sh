#!/bin/bash

BASEDIR=$(readlink -f $(dirname $0))

set -e

source ${BASEDIR}/config
source ${BASEDIR}/config.default

if [ ! -e "${SSH_KEY_PATH}" -o ! -e "${SSH_KEY_PATH}.pub" ]; then
  echo "Generating SSH keys..."
  rm -rf "${SSH_KEY_PATH}" "${SSH_KEY_PATH}.pub"
  mkdir -p "${SSH_KEY_PATH%/*}"
  ssh-keygen -t rsa -N "" -f "${SSH_KEY_PATH}" -C ${GERRIT_ADMIN_EMAIL}
fi

# Create containers
${BASEDIR}/createContainer.sh ${SUFFIX}
while [ -z "$(docker logs ${GERRIT_NAME} 2>&1 | grep "Gerrit Code Review [0-9..]* ready")" ]; do
    echo "Waiting gerrit ready."
    sleep 1
done
echo "Gerrit container is ready"
while [ -z "$(docker logs ${JENKINS_NAME} 2>&1 | grep "setting agent port for jnlp")" ]; do
    echo "Waiting jenkins ready."
    sleep 1
done
echo "Jenkins container is ready"
while [ -z "$(docker logs ${REDMINE_NAME} 2>&1 | grep "INFO success: nginx entered RUNNING state")" ]; do
    echo "Waiting redmine ready."
    sleep 1
done
echo "Redmine container is ready"

# Setup containers
${BASEDIR}/setupContainer.sh ${SUFFIX}
while [ -n "$(docker logs ${JENKINS_NAME} 2>&1 | tail -n 5 | grep 'Running from: /usr/share/jenkins/jenkins.war')" -o \
        -z "$(docker logs ${JENKINS_NAME} 2>&1 | tail -n 5 | grep 'setting agent port for jnlp')" ]; do
    echo "Waiting jenkins ready."
    sleep 1
done
echo "Jenkins container configured"

# Ensure redmine is running
while [ "$(curl -I http://${REDMINE_ADMIN_USER}:${REDMINE_ADMIN_PASSWD}@localhost/redmine 2>/dev/null | head -n1 | cut -d%' ' -f2)" -eq "200" ]; do
    echo "Waiting redmine service"
    sleep 1
done
echo "Redmine service running"

echo ">>>> Everything is ready."
