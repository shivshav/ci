#!/bin/bash

BASEDIR=$(readlink -f $(dirname $0))

echo ">>>>> Stop all"
${BASEDIR}/stop.sh
echo ">>>>> Start all"
${BASEDIR}/start.sh
