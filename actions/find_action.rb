module Canal
  class FindAction
    def initialize(api_handler)
      @api_handler = api_handler
    end

    def handle_command(args_a=nil, reply)
      return {} unless args_a && reply
      reply_text = ""
      time_s = args_a.first
      force_reply = false
      if time_s
        reply_text = "Searching available dates..\n\n"
        reply_text << find_availability(time_s, reply)
      else
        reply_text = "Cool, give me an hour like '18:30' or '17'"
        force_reply = true
      end
      { reply: reply_text, force_reply: force_reply }
    end

    def find_availability(time_s, reply)
      date = Date.today
      limit_date = Date.today.next_day(7)
      found_str = ""
      while date < limit_date
        date_t = DateParser.parse_date_and_time(date.strftime("%d-%m-%Y"), time_s)
        break unless date_t
        msg_h = @api_handler.check_date(date_t)
        if msg_h[:ok]
          found_str << ', ' if !found_str.empty?
          found_str << "#{date_t.full_date_string}: " + msg_h[:ok]
        end
        date = date.next_day
      end
      found_str.empty? ? "No available dates" : found_str + "\n\n ---"
    end

    def cancel
    end
  end
end
