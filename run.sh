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
WAIT_STR="Waiting for gerrit container."
while [ -z "$(docker logs ${GERRIT_NAME} 2>&1 | grep "Gerrit Code Review [0-9..]* ready")" ]; do
    WAIT_STR+="."
    printf "${WAIT_STR}\r"
    sleep 1
done
printf "\n"
echo "Gerrit container is ready"

WAIT_STR="Waiting for Jenkins container..."
while [ -z "$(docker logs ${JENKINS_NAME} 2>&1 | grep "setting agent port for jnlp")" ]; do
    WAIT_STR+="."
    printf "${WAIT_STR}\r"
    sleep 1
done
printf "\n"
echo "Jenkins container is ready"

WAIT_STR="Waiting redmine ready."
while [ -z "$(docker logs ${REDMINE_NAME} 2>&1 | grep "INFO success: nginx entered RUNNING state")" ]; do
    WAIT_STR+="."
    printf "${WAIT_STR}\r"
    sleep 1
done
printf "\n"
echo "Redmine container is ready"

# Setup containers
${BASEDIR}/setupContainer.sh ${SUFFIX}

# Ensure redmine is running
COUNTER=0
while [ "$(curl -I http://${REDMINE_ADMIN_USER}:${REDMINE_ADMIN_PASSWD}@localhost/redmine 2>/dev/null | head -n1 | cut -d$' ' -f2)" \
        -ne "200" ]; do
    # Max timeout
    if [ $COUNTER -eq "90" ]; then 
        exit 1; 
    fi
    echo "Waiting redmine service"
    echo "Status Code from redmine: $(curl -I http://${REDMINE_ADMIN_USER}:\${REDMINE_ADMIN_PASSWD}@localhost/redmine 2>/dev/null | head -n1 | cut -d$' ' -f2)"
    sleep 1
    let COUNTER=COUNTER+1
done
echo "Redmine service running"

echo ">>>> Everything is ready."
