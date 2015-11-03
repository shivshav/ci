#!/bin/bash

BASEDIR=$(readlink -f $(dirname $0))
SCRIPT_DIR=${BASEDIR}/img-scripts
NEXUS_DIR=nexus-docker
OPENLDAP_DIR=openldap-docker
GERRIT_DIR=gerrit-docker
JENKINS_DIR=jenkins-docker
REDMINE_DIR=redmine-docker
NGINX_DIR=nginx-docker
set -e

call_create_script() {
        SUBDIR=$1
        SCRIPT_NAME=$2
        echo "Current working dir is $(pwd)"
        cd ${SCRIPT_DIR}/${SUBDIR}
        source ${SCRIPT_NAME}
        cd ${BASEDIR}
}

# Add common variables.
source ${BASEDIR}/config
source ${BASEDIR}/config.default

# Create Nexus server.
if [ ${#NEXUS_WEBURL} -eq 0 ]; then
#    source ${SCRIPT_DIR}/nexus-docker/createNexus.sh
    call_create_script ${NEXUS_DIR} createNexus.sh
fi

# Create OpenLDAP server.
if [ ${#SLAPD_DOMAIN} -gt 0 -a ${#SLAPD_PASSWORD} -gt 0 ]; then
    ${SCRIPT_DIR}/openldap-docker/createOpenLDAP.sh ${SLAPD_PASSWORD} ${SLAPD_DOMAIN} ${GERRIT_ADMIN_UID} ${GERRIT_ADMIN_PWD} ${GERRIT_ADMIN_EMAIL} 
#    call_create_script ${OPENLDAP_DIR} createOpenLDAP.sh
fi

# Create Gerrit server container.
${SCRIPT_DIR}/gerrit-docker/createGerrit.sh ${GERRIT_WEBURL} ${LDAP_NAME} ${LDAP_ACCOUNTBASE} ${HTTPD_LISTENURL}
#call_create_script ${GERRIT_DIR} createGerrit.sh

# Create Jenkins server container.
${SCRIPT_DIR}/jenkins-docker/createJenkins.sh ${JENKINS_NAME} ${JENKINS_VOLUME} ${GERRIT_NAME} ${JENKINS_IMAGE_NAME} ${JENKINS_OPTS} ${TIMEZONE}

# Create Redmine server container.
${SCRIPT_DIR}/redmine-docker/createRedmine.sh ${PG_REDMINE_NAME} ${POSTGRES_IMAGE_NAME} ${REDMINE_NAME} ${REDMINE_IMAGE_NAME} ${REDMINE_VOLUME} ${GERRIT_VOLUME} ${LDAP_NAME} ${LDAP_ACCOUNTBASE}
#call_create_script ${REDMINE_DIR} createRedmine.sh

# Create Nginx proxy server container.
${SCRIPT_DIR}/nginx-docker/createNginx.sh ${HOST_NAME} ${GERRIT_NAME} ${JENKINS_NAME} ${REDMINE_NAME} ${NEXUS_NAME} ${NGINX_IMAGE_NAME} ${NGINX_NAME}
#call_create_script ${NGINX_DIR} createNginx.sh

