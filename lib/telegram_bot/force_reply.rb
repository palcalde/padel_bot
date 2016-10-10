module TelegramBot
  class ForceReply
    include Virtus.model
    attribute :chat, Channel
    attribute :force_reply, Boolean
    attribute :text, String

    def chat_friendly_name
      ""
    end

    def send_with(bot)
      bot.send_message(self)
    end

    def to_h
      {force_reply: true}
    end
  end

end
