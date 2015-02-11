# Description:
#   * Utility commands surrounding Hubot uptime.
#   * DOCOMOの雑談APIを利用した雑談
#
# Commands:
#   hubot おはよう - Reply with [おはようございます]
#   hubot 黙れ - Stop talk 5 minites and Reply with [ゴメンナサイ・・・]

shutup = false

module.exports = (robot) ->

  robot.respond /黙れ/, (msg) ->
    shutup = true
    console.log 'shutup = true'
    msg.send "ゴメンナサイ、静かにしてます :scream:"
    sleep 300, () ->
      shutup = false
      console.log 'shutup = false'

  robot.respond /おはよう/, (msg) ->
    msg.send "おはようございます :sunny:"

  robot.respond /ダメ/, (msg) ->
    unless shutup
      msg.send 'ゴメンナサイ、マダ勉強ブソクデス。オシエテクダサイ'

  robot.hear /誰か/, (msg) ->
    unless shutup
      msg.send "@#{msg.message.user.name} 私でよければ :man_with_turban:"

  robot.hear /ぬるぽ/, (msg) ->
    unless shutup
      msg.send 'ガッ'

  robot.hear /Yo/, (msg) ->
    unless shutup
      msg.send "@#{msg.message.user.name} Yo !! :sunglasses:"

  robot.hear /やっぱり.*[?？]$/, (msg) ->
    unless shutup
      msg.send "@#{msg.message.user.name} はい。そうですね :+1:"

  robot.hear /突然の(.*)$/, (msg) ->
    unless shutup
      try
        event = msg.match[1]
        length = parseInt(byteLength(event) / 2 + 2)
        top = '＿' + '人'.repeat(length) + '＿'
        bottom = '￣' + 'Ｙ'.repeat(length) + '￣'
        msg.send "#{top}\n＞　#{event}　＜\n#{bottom}"
      catch ex
        console.dir ex
    else
      msg.send ".........."

  # inspired from
  # http://fromatom.hatenablog.com/entry/2014/12/07/010447
  robot.respond /(\S+)/i, (msg) ->
    message = msg.match[1]
    return if shutup || !DOCOMO_API_KEY || !message

    ctx = robot.brain.get KEY_DOCOMO_CONTEXT || ''

    last_talk = robot.brain.get KEY_DOCOMO_CONTEXT_TTL
    if elapsedMinutes(last_talk) > TTL_MINUTES
      ctx = ''    # 前回会話から一定時間経ったらコンテキスト破棄

    nickname = msg.message.user.name

    talkToDocomoAI robot, message, nickname, ctx, (res)->
      # context 保存
      robot.brain.set KEY_DOCOMO_CONTEXT, res.context
      # 会話発生時間の保存
      robot.brain.set KEY_DOCOMO_CONTEXT_TTL, new Date().getTime()

      msg.send res.utt

elapsedMinutes = (from)->
  diff = new Date().getTime() - new Date(from).getTime()
  return parseInt(diff / (60 * 1000), 10)

talkToDocomoAI = (robot, msg, ctx, nickname, cb)->
  params =
    utt: msg
    nickname: nickname
    context: ctx
  robot.http(DOCOMO_AI_URL).post(JSON.stringify params) (err, r, body)->
    if err
      console.log "   ... error."
      console.dir err
    else
      res = JSON.parse body
      cb(res)

DOCOMO_API_KEY = process.env.DOCOMO_API_KEY
DOCOMO_API = 'https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue'
DOCOMO_AI_URL = "#{DOCOMO_API}?APIKEY=#{DOCOMO_API_KEY}"
KEY_DOCOMO_CONTEXT = 'docomo-talk-context'
KEY_DOCOMO_CONTEXT_TTL = 'docomo-talk-context-ttl'
TTL_MINUTES = 20

String.prototype.repeat = (num) ->
  new Array(num + 1).join(this)

byteLength = (str) ->
  count = 0
  for char,i in str
    count += if escape(char).length < 4 then 1 else 2
  count

sleep = (sec, callback) ->
  setTimeout callback, sec*1000

