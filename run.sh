#!/bin/sh

sudo -u ansible-setup ansible-playbook playbooks/laptop-work.yml -D

# if this is the first run (ie, no ansible-setup user has been created) you will need instead:
# ansible-playbook playbooks/laptop-work.yml -KD
