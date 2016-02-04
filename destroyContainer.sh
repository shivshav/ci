#!/bin/bash
SUFFIX=$1
BASEDIR=$(readlink -f $(dirname $0))
SCRIPT_DIR=${BASEDIR}/img-scripts

# Add common variables.
source ${BASEDIR}/config
source ${BASEDIR}/config.default

# Destroy Jenkins server container.
${SCRIPT_DIR}/jenkins-docker/destroyJenkins.sh

# Destroy Gerrit server container.
${SCRIPT_DIR}/gerrit-docker/destroyGerrit.sh

# Destroy Redmine server container.
${SCRIPT_DIR}/redmine-docker/destroyRedmine.sh

# Destroy DokuWiki server container.
${SCRIPT_DIR}/dokuwiki-docker/destroyDokuWiki.sh

# Destroy Nginx proxy server container.
${SCRIPT_DIR}/nginx-docker/destroyNginx.sh

# Destroy OpenLDAP server.
${SCRIPT_DIR}/openldap-docker/destroyOpenLDAP.sh

# Destroy Nexus server.
if [ ${#NEXUS_WEBURL} -eq 0 ]; then
    ${SCRIPT_DIR}/nexus-docker/destroyNexus.sh
fi

# Destroy jenkins slave volume.
${SCRIPT_DIR}/jenkins-slave-docker/destroyJenkinsSlave.sh

echo
echo "All applications removed."
