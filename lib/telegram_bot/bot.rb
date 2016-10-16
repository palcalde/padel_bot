# Override TelegramBot logic to trigger also a
# callback for each connection timeout
module TelegramBot
  class Bot
    def get_updates_with_timeout(opts = {}, timeout_block=nil, &block)
      return get_last_messages(opts) unless block_given?

      logger.info "starting get_updates loop"
      loop do
        messages = get_last_messages(opts)
        messages.compact.each do |message|
          next unless message
          logger.info "message from @#{message.chat.friendly_name}: #{message.text.inspect}"
          yield message
        end
        timeout_block.call if timeout_block
      end
    end
  end
end
