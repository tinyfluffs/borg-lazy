#!/usr/bin/env bash
set -ex

TEMPDIR=$(mktemp -d)
BACKUP="$1"

echo "$BACKUP"

command -v borg >/dev/null 2>&1 || { echo >&2 "Borg is not installed. Get it from your package manager (usually 'borgbackup' or 'borg').  Aborting."; exit 1; }

command -v sshfs >/dev/null 2>&1 || { echo >&2 "SSH FS is not installed. Get it from your package manager (usually 'sshfs' or 'sshfs-fuse').  Aborting."; exit 2; }

if [ ! -f "env" ]; then
	echo -e "
	\e[41mEnvironment file not found!
	Copy the example and edit: \`cp ./env.example ./env\`\e[39m"
	exit 3;
fi

source ./env

sshfs -p ${SSH_PORT} ${SSH}:${REMOTE_DIR} ${TEMPDIR}
cd ${TEMPDIR}
ls -lA
mkdir -p .borg-lazy/old
rm -rf ./*

borg extract -p ${LOCAL_DIR}::${BACKUP}
cd ${LOCAL_DIR}

echo 'Success!'
fusermount -u ${TEMPDIR}
