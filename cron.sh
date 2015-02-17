#!/bin/bash

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"

cd "/media/backup/git/github-mirror/github-backups"
#run the sync
./github-backups.rb
