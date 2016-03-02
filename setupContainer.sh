#!/bin/bash

BASEDIR=$(readlink -f $(dirname $0))
SCRIPT_DIR=${BASEDIR}/img-scripts

set -e

# Add common variables.
echo ">>>> Import common variables."
source ${BASEDIR}/config
source ${BASEDIR}/config.default

#Create administrator in Gerrit.
echo ">>>> Setup Gerrit."
${SCRIPT_DIR}/gerrit-docker/addGerritUser.sh ${GERRIT_WEBURL} ${GERRIT_ADMIN_UID} ${GERRIT_ADMIN_PWD} ${SSH_KEY_PATH}

#Integrate Jenkins with Gerrit.
echo ">>>> Setup Jenkins."
${SCRIPT_DIR}/jenkins-docker/setupJenkins.sh ${GERRIT_ADMIN_UID} ${GERRIT_ADMIN_EMAIL} ${SSH_KEY_PATH} ${LDAP_ACCOUNTBASE} ${JENKINS_NAME} ${GERRIT_NAME} ${GERRIT_SSH_HOST} ${GERRIT_WEBURL} ${JENKINS_WEBURL}  ${LDAP_NAME} ${LDAP_VOLUME} ${SLAPD_DOMAIN} ${NEXUS_REPO}

#Integrate Redmine with Openldap and import init data.
#echo ">>>> Setup Redmine."
#${SCRIPT_DIR}/redmine-docker/setupRedmine.sh

# Add Nexus configuration files and do general Nexus setup
echo ">>>> Setup Nexus."
${SCRIPT_DIR}/nexus-docker/setupNexus.sh ${LDAP_NAME} ${SLAPD_DOMAIN} ${LDAP_ACCOUNTBASE} ${NEXUS_NAME}

#Integrate DokuWiki with Openldap and import init data.
echo ">>>> Setup DokuWiki."
${SCRIPT_DIR}/dokuwiki-docker/setupDokuWiki.sh ${DOKUWIKI_NAME} ${LDAP_NAME} ${LDAP_ACCOUNTBASE} 

#Restart Nginx proxy.
echo ">>>> Restart Nginx proxy."
docker restart ${NGINX_NAME}

