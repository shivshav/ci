#!/bin/bash

BASEDIR=$(readlink -f $(dirname $0))
SCRIPT_DIR=./img-scripts

set -e

# Add common variables.
source ${BASEDIR}/config
source ${BASEDIR}/config.default

# Create OpenLDAP server.
#if [ ${#SLAPD_DOMAIN} -gt 0 -a ${#SLAPD_PASSWORD} -gt 0 ]; then
#    source ${SCRIPT_DIR}/openldap-docker/upgradeOpenLDAP.sh
#fi

# Upgrade Gerrit server container.
source ${SCRIPT_DIR}/gerrit-docker/upgradeGerrit.sh

while [ -z "$(docker logs ${GERRIT_NAME} 2>&1 | tail -n 4 | grep "Gerrit Code Review [0-9..]* ready")" ]; do
    echo "Waiting gerrit ready."
    sleep 1
done

# Upgrade Jenkins server container.
source ${SCRIPT_DIR}/jenkins-docker/upgradeJenkins.sh

while [ -z "$(docker logs ${JENKINS_NAME} 2>&1 | tail -n 5 | grep "Jenkins is fully up and running")" ]; do
    echo "Waiting jenkins ready."
    sleep 1
done

# Upgrade Redmine server container.
#source ${SCRIPT_DIR}/redmine-docker/upgradeRedmine.sh
#
#while [ -z "$(docker logs ${REDMINE_NAME} 2>&1 | tail -n 5 | grep 'INFO success: nginx entered RUNNING state')" ]; do
#    echo "Waiting redmine ready."
#    sleep 1
#done
#
# Upgrade Nginx proxy server container.
source ${SCRIPT_DIR}/nginx-docker/upgradeNginx.sh
