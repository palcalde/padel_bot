module Canal
  class ReserveAction
    def initialize(api_handler)
      @api_handler = api_handler
      @date = nil
      @state = :init
    end

    def force_reserve(args_a, reply)
      return {} unless args_a
      date = DateParser.parse_date_and_time(args_a[0], args_a[1])
      if date
        msg_h = @api_handler.reserve_date(date)
        reply_text = ""
        reply_text << "\n\n #{date.full_date_string} "
        reply_text << msg_h.values.first if msg_h
        reset_state
      else
        reply_text = "Wrong format, try again"
      end
      {reply: reply_text, force_reply: false}
    end

    def handle_command(args_a, reply)
      return {} unless args_a && reply
      puts "args are #{args_a}"
      reply_text = ""
      case @state
      when :init
        if args_a.count == 0
          @state = :date
          reply_text = "Ok! give me a date! Like '18/10/16' or only the day like '18'"
        elsif args_a.count == 2
          @date = DateParser.parse_date_and_time(args_a[0], args_a[1])
          if @date
            reply_text = "Are you sure u want me to reserve #{@date.full_date_string}? (yes/no)"
            @state = :confirmation
          else
            reply_text = "Wrong format, try again"
          end
        end
      when :date
        puts "getting date"
        date = args_a[0]
        date = DateParser.parse_date_and_time(args_a[0])
        puts "date is #{date}"

        if date
          @date = args_a[0]
          @state = :time
          reply_text = "Ok.. what hour?"
        else
          reply_text = "Wrong format, try again"
        end
      when :time
        time = args_a[0]
        @date = DateParser.parse_date_and_time(@date, time)
        puts "date with time is #{@date}"
        if @date
          reply_text = "Are you sure u want me to reserve #{@date.full_date_string}? (yes/no)"
          @state = :confirmation
        else
          reply_text = "Wrong format, try again"
        end
      when :confirmation
        confirmed = args_a[0]
        if confirmed.downcase == 'yes'
          msg_h = @api_handler.reserve_date(@date)
          reply_text << "\n\n #{@date.full_date_string} "
          reply_text << msg_h.values.first if msg_h
          reset_state
          reply_text
        else
          cancel
          reply_text = "Ok, reserve operation cancelled"
        end
      end

      force_reply = @state != :init
      {reply: reply_text, force_reply: force_reply}
    end


    def cancel
      reset_state
    end

    def reset_state
      @state = :init
      @date = nil
    end
  end
end
