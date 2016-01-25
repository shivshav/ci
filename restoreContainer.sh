#1/bin/bash

BASEDIR=$(readlink -f $(dirname $0))
SCRIPT_DIR=${BASEDIR}/img-scripts

set -e

# Add common variables
source ${BASEDIR}/config
source ${BASEDIR}/config.default

# Restore Redmine Postgres database
echo ">>>> Restore Redmine Database."
${SCRIPT_DIR}/redmine-docker/restoreRedmineBackup.sh ${SCRIPT_DIR}/redmine-docker/backups || { 
    echo "Restore failed for Redmine database!"
    exit 1
}

# Restore Redmine container data volumes

# Restore Gerrit Postgres database
# Restore Gerrit container data volumes

# Restore Jenkins container data volumes
# Restore Dokuwiki container data volumes
# Restore Nexus container data volumes
# Restore Proxy container data volumes
# Restore LDAP container data volumes

echo ">>>> All container backups successfully restored!"
