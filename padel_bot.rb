require 'telegram_bot'
require 'pp'
require 'logger'
require_relative 'actions/check_action'
require_relative 'actions/find_action'
require_relative 'actions/reminder_action'
require_relative 'actions/reserve_action'
require_relative 'network/api_handler'
require_relative 'network/network_manager'
require_relative 'parser'
require_relative 'payload'
require_relative 'helpers'
require_relative 'lib/telegram_bot/force_reply'
require_relative 'lib/telegram_bot/bot'
require_relative 'lib/telegram_bot/out_message'

include Canal

logger = Logger.new(STDOUT, Logger::DEBUG)
PROXY_ENABLED = false

proxy = 'http://127.0.0.1:8888' if PROXY_ENABLED
Excon.defaults[:ssl_verify_peer] = false

bot = TelegramBot.new(token: ENV['PADEL_BOT'], logger: logger, proxy: proxy)

api_handler = ApiHandler.new(proxy: proxy)
action_handlers = { check: CheckAction.new(api_handler),
                    reserve: ReserveAction.new(api_handler),
                    find: FindAction.new(api_handler),
                    reminder: ReminderAction.new(api_handler) }

logger.debug "starting telegram bot"
pending_action = nil

timeout_block = Proc.new {
  date = action_handlers[:reminder].date
  reply = action_handlers[:reminder].reply
  p "timeout block triggered with date #{date} and reminder #{reply}"
  if date && reply
    if date.to_date < Date.today.next_day(7)
      p "Reminder fired for date #{date}"
      date_s = date.strftime("%d-%m-%Y %H:%M")
      reply.text = "Heyyyy! Reminder fired \o/"
      r = action_handlers[:reserve].force_reserve(date_s.split, reply)
      if r[:reply]
        reply.text << r[:reply]
        reply.send_with(bot)
        action_handlers[:reminder].cancel
      end
    else
      p "Reminder #{date.to_date} is still not bookable at #{Date.today.next_day(7)}"
    end
  end
}

bot.get_updates_with_timeout({fail_silently: true}, timeout_block) do |message|
  logger.info "@#{message.from.username}: #{message.text}"
  puts "pending_action #{pending_action}"
  command = message.get_command_for(bot) || ''
  pending_action = nil if command.split.first == '/cancel'
  action = pending_action ? pending_action : command.split.first
  args = pending_action ? command.split : command.split.drop(1)
  p "message received #{message.id}"
  message.reply do |reply|
    reply.text = ""
    case action
    when '/start'
      reply.text = "What's up guys, I'm here to serve you. Type the backslash '/' to see what I can do!"
    when '/check'
      p "sending check args #{args}"
      r = action_handlers[:check].handle_command(args, reply)
      reply.text << r[:reply]
      pending_action = r[:force_reply] ? '/check' : nil
    when '/reserve'
      p "sending reserve args #{args}"
      r = action_handlers[:reserve].handle_command(args, reply)
      reply.text << r[:reply]
      pending_action = r[:force_reply] ? '/reserve' : nil
    when '/reminder'
      p "sending reminder args #{args}"
      reply.reply_to = message
      r = action_handlers[:reminder].handle_command(args, reply)
      reply.text << r[:reply]
      pending_action = r[:force_reply] ? '/reminder' : nil
    when '/cancel'
      reply.text = "Ok, all cancelled!"
      pending_action = nil
      action_handlers.each do |_action, _handler|
        _handler.cancel
      end
    when '/find'
      p "sending search args #{args}"
      r = action_handlers[:find].handle_command(args, reply)
      reply.text << r[:reply]
      pending_action = r[:force_reply] ? '/find' : nil

    when '/whowillwin'
      reply.text << "Pablo and Javi, of course!"
    else
      if action
        reply.text = "Uhmm.. dunno what u mean :/" unless !action
      else
        reply.text = ""
      end
    end

    reply.parse_mode = 'Markdown'
    multiple_resp = reply.text.split("\n\n")    # Divide msg and send them separatelly
    multiple_resp.each do |msg|
      reply.text = msg
      reply.reply_markup = TelegramBot::ForceReply.new if pending_action
      reply.reply_to = message if pending_action
      reply.send_with(bot)
    end
  end
end
