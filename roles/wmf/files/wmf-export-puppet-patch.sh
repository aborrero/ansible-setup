#!/bin/bash

PUPPETMASTER="$1"
if [ -z "$PUPPETMASTER" ] ; then
	echo "E: no puppetmaster specified" >&2
	exit 1
fi

if [ "$PUPPETMASTER" == "tools" ] ; then
    PUPPETMASTER="tools-puppetmaster-02.tools.eqiad1.wikimedia.cloud"
fi
if [ "$PUPPETMASTER" == "toolsbeta" ] ; then
    PUPPETMASTER="toolsbeta-puppetmaster-04.toolsbeta.eqiad1.wikimedia.cloud"
fi
if [ "$PUPPETMASTER" == "paws" ] ; then
    PUPPETMASTER="paws-puppetmaster-01.paws.eqiad1.wikimedia.cloud"
fi

PATCH="wmf-export-puppet.patch"
PATCH_PATH="../${PATCH}"
git diff origin/HEAD > ${PATCH_PATH}
scp ${PATCH_PATH} ${PUPPETMASTER}:
SSH_COMMAND="{ cd /var/lib/git/operations/puppet ;
		sudo git checkout -f ;
		sudo git clean -fd ;
		sudo git pull --rebase ;
		sudo patch -p1 <~/${PATCH} ;}"
ssh $PUPPETMASTER $SSH_COMMAND
