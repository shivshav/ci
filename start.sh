#!/bin/bash
set -e
#set -x

source ~/ci/config
source ~/ci/config.default

# Start OpenLDAP
if [ -n "$(docker ps -a | grep ${LDAP_NAME})" ]; then
    docker start ${LDAP_NAME}
fi

# Start Gerrit.
docker start ${PG_GERRIT_NAME}

while [ -z "$(docker logs ${PG_GERRIT_NAME} 2>&1 | tail -n 4 | grep 'autovacuum launcher started')" ]; do
    echo "Waiting postgres ready."
    sleep 1
done

docker start ${GERRIT_NAME}

while [ -z "$(docker logs ${GERRIT_NAME} 2>&1 | tail -n 4 | grep "Gerrit Code Review [0-9..]* ready")" ]; do
    echo "Waiting gerrit ready."
    sleep 1
done

# Start Jenkins.
docker start ${JENKINS_NAME}

while [ -z "$(docker logs ${JENKINS_NAME} 2>&1 | tail -n 15 | grep "Jenkins is fully up and running")" ]; do
    echo "Waiting jenkins ready."
    sleep 1
done

# Start Redmine.
docker start ${PG_REDMINE_NAME}

while [ -z "$(docker logs ${PG_REDMINE_NAME} 2>&1 | tail -n 4 | grep 'autovacuum launcher started')" ]; do
    echo "Waiting postgres ready."
    sleep 1
done

docker start ${REDMINE_NAME}

while [ -z "$(docker logs ${REDMINE_NAME} 2>&1 | tail -n 5 | grep 'INFO success: nginx entered RUNNING state')" ]; do
    echo "Waiting redmine ready."
    sleep 1
done

# Start Nexus.
if [ -n "$(docker ps -a | grep ${NEXUS_NAME})" ]; then
    docker start ${NEXUS_NAME}
fi

# start phpldapadmin
if [ -n "$(docker ps -a | grep ${PHPLDAPADMIN_NAME})" ]; then
    docker start ${PHPLDAPADMIN_NAME}
fi

# start dokuwiki 
if [ -n "$(docker ps -a | grep ${DOKUWIKI_NAME})" ]; then
    docker start ${DOKUWIKI_NAME}
fi

# Start proxy
docker start ${NGINX_NAME}



echo ">>>> Everything is ready."
