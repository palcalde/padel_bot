# Excon doesn't seem to provide an accessor to get the full url of the response,
# lets add one and let network_manager set it
module Excon
  class Response
    def requested_url=(url)
      @requested_url = url
    end

    def requested_url
      @requested_url || ""
    end
  end
end

class Time
  def year_month_day
    self.strftime("%Y-%m-%dT00:00:00")
  end

  def minutes_seconds
    self.strftime("%H:%M")
  end

  def full_date_string
    self.strftime("%d-%m-%Y at %H:%M")
  end
end

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
