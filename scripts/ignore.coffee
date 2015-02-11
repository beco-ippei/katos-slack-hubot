# Description:
#   ignore not permitted messages.

permitted_rooms = process.env.HUBOT_PERMITTED_ROOMS?.split(',') || []

permitted = (room, user) ->
  # DM to bot OR message from permitted room
  user == room || room in permitted_rooms

module.exports = (robot) ->

  receive_org = robot.receive
  robot.receive = (msg)->
    user = if msg.user?.name? then msg.user.name.toLowerCase() else null
    room = if msg.room? then msg.room.toLowerCase() else null

    if permitted room, user    # allow permitted room or user (direct message)
      receive_org.bind(robot)(msg)
    else
      console.log "ignored messge, from #{user} at #{room}"

