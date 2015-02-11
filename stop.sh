#!/bin/sh
cd `dirname $0`
cmd=`pwd`/node_modules/.bin/hubot

pid=`pgrep -f $cmd`
if [ "$?" != "0" ]; then
  echo "hubot プロセスがありません"
  exit 0
fi

for i in $pid; do
  echo "kill $i"
  kill $i
done

