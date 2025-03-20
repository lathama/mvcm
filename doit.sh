#!/bin/bash

declare -A MVCM_actions
declare -a MVCM_hosts

if [ ! -f ~/.ssh/config ]
then
  echo "Host *" > ~/.ssh/config
  echo "StrictHostKeyChecking no" >> ~/.ssh/config
  chmod 400 ~/.ssh/config
else
  echo "SSH config file exists"
fi

echo "Loading Inventory"
if [ -f inventory.mvcm ]
then
  source inventory.mvcm
else
  echo "inventory.mvcm not found"
fi

echo "Loading Configuration"
if [ -f config.mvcm ]
then
  source config.mvcm
else
  echo "config.mvcm not found"
fi

echo "Loading Actions"
for actionsfile in actions/*.mvcm
do
  source $actionsfile
done

echo "Loading Secrets"

for secretsfile in secrets/*.mvcm
do
  source $secretsfile
done

for host in "${MVCM_hosts[@]}"
do
  echo "Attempting to connect to " $host
  for mvcm_user in "${!MVCM_actions[@]}"
  do
    thisaction="ssh -l $mvcm_user $host ${MVCM_actions[$mvcm_user]}"
    echo "Attempting to exec $thisaction"
    if [ $MVCM_USEPASSWORD ]
    then 
      sshpass -p ${MVCM_password[$mvcm_user]} $thisaction
    else
      $thisaction
    fi
  done
done
