# ci project [![Build Status](https://travis-ci.org/shivshav/ci.svg?branch=master)](https://travis-ci.org/shivshav/ci)
Development branch [![Build Status](https://travis-ci.org/shivshav/ci.svg?branch=develop)](https://travis-ci.org/shivshav/ci)
## Features
* Continuous integration system base on other docker projects.
* Create a Gerrit container with PostgreSQL as backend and OpenLDAP as authorization server.
* Create a Jenkins container with OpenLDAP as authorization server that integrates with Gerrit.
* Create a Jenkins container slave workspace volume.
* Create a Redmine container with OpenLDAP as authorization server.
* Create a Dokuwiki container with OpenLDAP as authorization server.
* Create a Nexus container as local maven repository.
* Create an Nginx container as a reverse proxy of the Gerrit, Jenkins, Redmine, Dokuwiki, Nexus with SSO through OpenLDAP.
* Optionally create a OpenLDAP container.
* Import a project to demonstrate the configuration of Gerrit, Jenkins, Redmine which including:
  * Using Jenkins gerrit plugin to trigger builds from gerrit.
  * Using Jenkins docker plugin to trigger builds on a dockerized slave node.

## Prerequisites
    Docker service installed on host.
    Git installed on host.
    A OpenLDAP or AD server with anonymous binding configuration. (Optional)
    An user account with email in the OpenLDAP or AD server. (Optional)

## Clone repository and all submodules
    git clone --recursive https://github.com/shivshav/ci.git

## Create all containers.
    ## Edit variables according to your environment.
    vi $PROJECT_ROOT/config
    ## Start all containers.
    $PROJECT_ROOT/run.sh

## Access those services.
    ## Gerrit
    http://your.server.url/gerrit
    Login using <admin uid> and <admin password> from config.
    ## Jenkins
    http://your.server.url/jenkins
    ## Redmine
    http://your.server.url/redmine
    Default Administrator's username and password is admin/admin.
    ## Dokuwiki
    http://your.server.url/dokuwiki
    Login using <admin uid> and <admin password> from config.
    ## Nexus
    http://your.server.url/nexus
    Default Administrator's username and password is admin/admin123.

## Stop and restart all containers.
    ## Stop all
    $PROJECT_ROOT/stop.sh
    ## Restart all
    $PROJECT_ROOT/start.sh

## Upgrade containers.(Use with caution!)
    ## Upgrade Gerrit, Jenkins, Redmine, Nginx
    ## Keep all data containers untouched.
    ## Gerrit 2.10.6 -> 2.11.2 has been tested.
    $PROJECT_ROOT/upgradeContainer.sh

## Destroy all containers.(Use with caution!) 
    $PROJECT_ROOT/destroyContainer.sh
