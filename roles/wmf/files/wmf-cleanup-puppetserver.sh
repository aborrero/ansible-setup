#!/bin/bash

PUPPETSERVER="$1"
if [ -z "$PUPPETSERVER" ] ; then
	echo "E: no puppetserver specified" >&2
	exit 1
fi

if [ "$PUPPETSERVER" == "tools" ] ; then
    PUPPETSERVER="tools-puppetserver-01.tools.eqiad1.wikimedia.cloud"
fi
if [ "$PUPPETSERVER" == "toolsbeta" ] ; then
    PUPPETSERVER="toolsbeta-puppetserver-1.toolsbeta.eqiad1.wikimedia.cloud"
fi

SSH_COMMAND="{ cd /srv/git/operations/puppet/ ;
		sudo git checkout -f ;
		sudo git clean -fd ;
		sudo systemctl start puppet-git-sync-upstream.service ;}"
echo "INFO: cleaning up $PUPPETSERVER"
echo
ssh $PUPPETSERVER $SSH_COMMAND
