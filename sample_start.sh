#!/bin/sh
PATH=${PATH}:/usr/local/bin

# 利用する際には、各環境変数を設定して "start.sh" にRenameして利用して下さい

export HUBOT_SLACK_TOKEN=xoxb-1111111-xxxxxxxxxxxxxxxxxxxxxxx

# set hubot responsable rooms
export HUBOT_VALID_ROOMS=xxxx,yyyy
# set hubot responsable users
export HUBOT_VALID_USERS=aaaa,bbbb,cccc,dddd

./bin/hubot --adapter slack >>logs/hubot.log 2>/dev/null &

