#!/bin/ksh

###########################################
#                                         #
# Take input from pipe and send to hobbit #
# server using appropriate binary for     #
# current platform.                       #
#                                         #
# Martin Colello                          # 
# 02/09/2011                              #
#                                         #
###########################################

FIRST=TRUE
while read LINE
do
  if [[ $FIRST = 'TRUE' ]]
  then
    FIRST=FALSE
    SEND=$LINE
  else
  SEND="$SEND
$LINE"
  fi
done

UNAME=`uname -a`

echo $UNAME | grep Linux > /dev/null 2>&1
if [[ $? -eq 0 ]]
then
/usr/local/admin/scripts/hobbit/bb_x64_linux 10.97.26.11 "$SEND"
exit
fi

echo $UNAME | grep sparc > /dev/null 2>&1
if [[ $? -eq 0 ]]
then
/usr/local/admin/scripts/hobbit/bb 10.97.26.11 "$SEND"
exit
fi

echo $UNAME | grep i386 > /dev/null 2>&1
if [[ $? -eq 0 ]]
then
/usr/local/admin/scripts/hobbit/bbx86 10.97.26.11 "$SEND"
exit
fi

echo $UNAME | grep Ubuntu > /dev/null 2>&1
if [[ $? -eq 0 ]]
then
/usr/local/admin/scripts/hobbit/bb_debian 10.97.26.11 "$SEND"
exit
fi
