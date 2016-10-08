require 'telegram_bot'
require 'pp'
require 'logger'
require_relative 'actions/reserve_action'
require_relative 'actions/lookup_action'
require_relative 'actions/reminder_action'
require_relative 'network/network_manager'
require_relative 'parser'
require_relative 'payload'
require_relative 'helpers'

include Canal

logger = Logger.new(STDOUT, Logger::DEBUG)

proxy = 'http://127.0.0.1:8888'
Excon.defaults[:ssl_verify_peer] = false

bot = TelegramBot.new(token: ENV['PADEL_BOT'], logger: logger, proxy: proxy)

network_manager = Canal::Network::NetworkManager.new(logger: logger,
                                                     proxy: proxy)
action_handlers = { reserve: ReserveAction.new(network_manager),
                    lookup: LookupAction.new(network_manager),
                    reminder: ReminderAction.new(network_manager) }

logger.debug "starting telegram bot"
pending_action = nil

bot.get_updates(fail_silently: true) do |message|
  logger.info "@#{message.from.username}: #{message.text}"
  puts "pending_action #{pending_action}"
  command = message.get_command_for(bot)
  pending_action = nil if command.split.first == '/cancel'
  action = pending_action ? pending_action : command.split.first
  args = pending_action ? command.split : command.split.drop(1)
  message.reply do |reply|
    case action
    when '/reserve'
      p "sending reserve args #{args}"
      r = action_handlers[:reserve].handle_command(args, reply)
      pending_action = r[:force_reply] ? '/reserve' : nil
    when '/reminder'
      p "sending reminder args #{args}"
      r = action_handlers[:reminder].handle_command(args, reply)
      pending_action = r[:force_reply] ? '/reminder' : nil
    when '/cancel'
      reply.text = "Ok, all cancelled!"
      pending_action = nil
      action_handlers.each do |action, handler|
        handler.cancel
      end
    when '/lookup'
      p "sending lookup args #{args}"
      r = action_handlers[:lookup].handle_command(args, reply)
      pending_action = r[:force_reply] ? '/lookup' : nil
    else
      reply.text = "Uhmm.. dunno what u mean :/"
    end
      reply.send_with(bot)
  end
end
