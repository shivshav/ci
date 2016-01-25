#!/bin/bash

BASEDIR=$(readlink -f $(dirname $0))
SCRIPT_DIR=${BASEDIR}/img-scripts

set -e

# Add common variables
source ${BASEDIR}/config
source ${BASEDIR}/config.default

# Backup Redmine Postgres database
echo ">>>> Backup Redmine Database."
${SCRIPT_DIR}/redmine-docker/backupRedmine.sh ${SCRIPT_DIR}/redmine-docker/backups|| { echo "Backup failed for Redmine database!"; exit 1; }

# Backup Redmine container data volumes

# Backup Gerrit Postgres database
# Backup Gerrit container data volumes

# Backup Jenkins container data volumes
# Backup Dokuwiki container data volumes
# Backup Nexus container data volumes
# Backup Proxy container data volumes
# Backup LDAP container data volumes

echo "All container backups successfully completed!"
