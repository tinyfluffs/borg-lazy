#!/usr/bin/env bash

ENVFILE=$1

TEMPDIR=$(mktemp -d)

command -v borg >/dev/null 2>&1 || { echo >&2 "Borg is not installed. Get it from your package manager (usually 'borgbackup' or 'borg').  Aborting."; exit 1; }

command -v sshfs >/dev/null 2>&1 || { echo >&2 "SSH FS is not installed. Get it from your package manager (usually 'sshfs' or 'sshfs-fuse').  Aborting."; exit 2; }

if [ ! -f "env" ]; then
	echo -e "
	\e[41mEnvironment file not found!
	Copy the example and edit: \`cp ./env.example ./env\`\e[39m"
	exit 3;
fi

source ${ENVFILE}

if [ ! -d "$LOCAL_DIR" ]; then
	echo -e "\e[92m$(cat LICENSE | sed 's/^/        /')
	
	\e[36mIt appears you are running this script for the first time!
	
	The default encryption method is 'keyfile'. Your keyfile can be found at: ${HOME}/.config/borg/keys/$(basename ${LOCAL_DIR})
	To change the encryption method, set the variable ENCRYPTION=xxx
	
	If no password is supplied, only the keyfile will be used for encryption. To disable encryption entirely, set ENCRYPTION=none
	
	For advanced configuration, please refer to the Borg documentation:
	https://borgbackup.readthedocs.io/en/stable/usage/init.html#encryption-modes
	
	--------------\e[39m
	"

	mkdir -p $(dirname $LOCAL_DIR)
	borg init -e ${ENCRYPTION} ${LOCAL_DIR}
	borg upgrade --disable-tam ${LOCAL_DIR}
fi

sshfs -p ${SSH_PORT} ${SSH}:${REMOTE_DIR} ${TEMPDIR}
cd ${TEMPDIR}
borg create -p ${LOCAL_DIR}::{now:%Y-%m-%dT%H:%M:%S} .
cd ${LOCALDIR}

echo 'Success!'
fusermount -u ${TEMPDIR}
