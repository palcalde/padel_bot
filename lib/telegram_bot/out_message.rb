module TelegramBot
  class OutMessage
    include Virtus.model
    attribute :reply_markup, ForceReply

    def to_h
      message = {
        text: text,
        chat_id: chat.id
      }
      message[:reply_to_message_id] = reply_to.id unless reply_to.nil?
      message[:parse_mode] = parse_mode unless parse_mode.nil?
      message[:disable_web_page_preview] = disable_web_page_preview unless disable_web_page_preview.nil?
      message[:reply_markup] = reply_markup.to_h.to_json unless reply_markup.nil?
      message
    end
  end
end

