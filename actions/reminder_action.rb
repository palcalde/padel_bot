module Canal
  class ReminderAction
    def initialize(api_handler)
      @api_handler = api_handler
      @date = nil
      @reply = nil
    end

    def date
      @date
    end

    def reply
      @reply
    end

    def handle_command(args_a=[], reply)
      reply_text = ""
      if args_a.count == 0
        p "args are 0"
        if @date
          reply_text = "Your reminder is #{@date.full_date_string}"
        else
          reply_text = "No reminder yet, use something like '/reminder 26/10/16 18:00' to set up one"
        end
      elsif args_a.count == 2
        if date = DateParser.parse_date_and_time(args_a[0], args_a[1])
          if date.to_date >= Date.today.next_day(7)
            @reply = reply
            @date = date
            reply_text = "Reminder set to #{@date.full_date_string}"
          else
            reply_text = "No reminder needed. You can already book this date, use /reserve :)"
          end
        else
          reply_text.text = "Wrong date format, try again please"
        end
      else
        reply_text = "/reminder only accepts two params, date and time"
      end

      {reply: reply_text, force_reply: false}
    end

    def cancel
      @date = nil
      @reply = nil
    end
  end
end
