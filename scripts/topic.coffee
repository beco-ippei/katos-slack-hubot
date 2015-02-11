# Description:
#   save and show topic for daily-standup
#
# Commands:
#   [hubot] topic add <topic-message>   - add topic and show topic-id
#   [hubot] topic (rm|remove|del(ete)) <topic-id> - delete topic and show removed topic-id/message
#   [hubot] topic list - show topic list (topic-id / message)
#
# Dependencies:
#   None
#
# Configuration:
#   None
CronJob = require('cron').CronJob

topic_list = (robot) ->
  topics = robot.brain.get 'topic'

  _list = []
  for id of topics
    _list.push "[#{id}]: #{topics[id]}"
  return _list

escape = (msg) ->
  return msg.replace /@/g, '[at]'

module.exports = (robot) ->

  robot.respond /topic\ +add\ +(.*)/, (msg) ->
    try
      id = robot.brain.get('topic_id')+1 ? 1
      robot.brain.set 'topic_id', id

      topics = robot.brain.get('topic') ? {}
      topics[id] = msg.match[1]
      #TODO urlに "<...>" がついて、とれていないバグ(?)がある様子
      robot.brain.set 'topic', topics

      console.log "add topic : #{topics[id]}"
      msg.send "topic added - [#{id}]: #{escape topics[id]}"
    catch ex
      console.dir ex

  robot.respond /topic\ +(?:rm|remove|del(?:ete)?)\ +(.*)/, (msg) ->
    try
      unless match = /^(\d+)/.exec msg.match[1]
        msg.send 'id は数値のみ有効'
        return

      id = match[0]
      topics = robot.brain.get('topic') ? {}
      unless topic_text = topics[id]
        msg.send '指定id の topic はありません'
        return

      delete topics[id]
      robot.brain.set 'topic', topics

      console.log "remove topic : #{topic_text}"
      msg.send "topic removed - [#{id}]: #{escape topic_text}"
    catch ex
      console.dir ex

  robot.respond /topic\ +list/, (msg) ->
    try
      msg.send "Topics:\n" + topic_list(robot).join "\n"
    catch ex
      console.dir ex

  ## *(sec) *(min) *(hour) *(day) *(month) *(day of the week)
  #new CronJob(
  #  '0 5 10,14,18 * * 1,2,3,4,5',
  #  () ->
  #    console.log 'start cron-job : topic list'
  #    robot.send {room: 'general'}, "Topics:\n" + topic_list(robot).join "\n"
  #).start()

