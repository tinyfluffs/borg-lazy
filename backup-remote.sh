#!/usr/bin/env bash

## Backup from a remote directory to another remote directory

ENVFILE=$1
TEMPDIR=$(mktemp -d)

command -v borg >/dev/null 2>&1 || { echo >&2 "Borg is not installed. Get it from your package manager (usually 'borgbackup' or 'borg').  Aborting."; exit 1; }

command -v sshfs >/dev/null 2>&1 || { echo >&2 "SSH FS is not installed. Get it from your package manager (usually 'sshfs' or 'sshfs-fuse').  Aborting."; exit 2; }

if [ ! -f "${ENVFILE}" ]; then
	echo -e "
	\e[41mEnvironment file not found!
	Copy the example and edit: \`cp ./env.example ./env\`\e[39m"
	exit 3;
fi

source ${ENVFILE}

BORG_SSH_DIR="${BORG_SSH}:${BORG_BACKUP_DIR}"

if [ "$2" = "init" ]; then
	echo -e "\e[92m$(cat LICENSE | sed 's/^/        /')
	
	\e[36mIt appears you are running this script for the first time!
	
	The default encryption method is 'keyfile'. Your keyfile can be found at: ${HOME}/.config/borg/keys/$(basename ${BACKUP_DIR})
	To change the encryption method, set the variable ENCRYPTION=xxx
	
	If no password is supplied, only the keyfile will be used for encryption. To disable encryption entirely, set ENCRYPTION=none
	
	For advanced configuration, please refer to the Borg documentation:
	https://borgbackup.readthedocs.io/en/stable/usage/init.html#encryption-modes
	
	--------------\e[39m
	"

	borg init -e ${ENCRYPTION} ${BORG_SSH_DIR}
	borg upgrade --disable-tam ${BORG_SSH_DIR}
	exit 0;
fi

borg create -p ${BORG_SSH_DIR}::{now:%Y-%m-%dT%H:%M:%S} ${DATA_DIR}

echo 'Success!'
