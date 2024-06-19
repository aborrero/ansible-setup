#!/bin/bash

PUPPETMASTER="$1"
if [ -z "$PUPPETMASTER" ] ; then
	echo "E: no puppetmaster specified" >&2
	exit 1
fi

if [ "$PUPPETMASTER" == "tools" ] ; then
    PUPPETMASTER="tools-puppetserver-01.tools.eqiad1.wikimedia.cloud"
fi
if [ "$PUPPETMASTER" == "toolsbeta" ] ; then
    PUPPETMASTER="toolsbeta-puppetserver-1.toolsbeta.eqiad1.wikimedia.cloud"
fi

SSH_COMMAND="{ cd /srv/git/operations/puppet/ ;
		sudo git checkout -f ;
		sudo git clean -fd ;
		sudo systemctl start puppet-git-sync-upstream.service ;}"
echo "INFO: cleaning up $PUPPETMASTER"
echo
ssh $PUPPETMASTER $SSH_COMMAND
