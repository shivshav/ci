#!/bin/bash

BASEDIR=$(readlink -f $(dirname $0))

echo ">>>>> Destroy all"
${BASEDIR}/destroyContainer.sh
echo ">>>>> Run"
${BASEDIR}/run.sh
