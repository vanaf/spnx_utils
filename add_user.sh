#!/bin/bash -x
set -e

# mysql settings
MYSQL_USER='root'
MYSQL_PASS='pass'
MYSQL_URL='127.0.0.1'
MYSQL_DB='sphinx'

MYSQL_CLI_SETTINGS="-h${MYSQL_URL} -u${MYSQL_USER} -p${MYSQL_PASS} -d${MYSQL_DB}"

# new user parameters
NEW_EXTID=$1
NEW_TYPE='EMP'
NEW_NAME=$2
NEW_DESCRIPTION=$3
NEW_POS=$4
NEW_TABID=$5
NEW_CODEKEY=$6
NEW_EXPTIME=$7
NEW_PARENT_ID=$8

if [ "$#" -ne 8 ]; then
  echo "Invalid argument number"
  echo "Usage: ./add_user.sh [EXTID] [NAME] [DESCRIPTION] [POS] [TABID] [CODEKEY] [EXPTIME]"
  exit 1
fi

# 

QUERY="INSERT INTO personal (PARENT_ID, 
                             EXTID, TYPE, 
                             NAME, DESCRIPTION, 
                             POS, TABID, 
                             CODEKEY, 
                             EXPTIME) 
                     VALUES ('$NEW_PARENT_ID', 
                             '$NEW_EXTID', 
                             '$NEW_TYPE', 
                             '$NEW_NAME', 
                             '$NEW_DESCRIPTION', 
                             '$NEW_POS', 
                             '$NEW_TABID', 
                             unhex(concat('18',hex('$NEW_CODEKEY'),'00000000')),
                              $NEW_EXPTIME);"

CHECK_QUERY="SELECT id, name FROM personal WHERE name=\"$NEW_NAME\""
SYNC_QUERY="UPDATE parami SET PARAMVALUE=1 WHERE name='SYNCDB_REQUEST';"
GET_ID_QUERY="SELECT id FROM personal WHERE name LIKE '%$NEW_NAME%' LIMIT 0,1;"

# add user and sync db
if [[ $(mysql $MYSQL_CLI_SETTINGS -e"$CHECK_QUERY") == *"$NEW_NAME"* ]]; then
  echo "This record already exists in database"
  exit 1
else
  mysql $MYSQL_CLI_SETTINGS -e"$QUERY $SYNC_QUERY"
  echo "User is added successfuly"
  echo "New user has id" $(mysql $MYSQL_CLI_SETTINGS -e"$GET_ID_QUERY" | sed -n 2p)
fi
