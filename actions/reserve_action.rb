module Canal
  class ReserveAction
    def initialize(api_handler)
      @api_handler = api_handler
      @date = nil
      @state = :init
    end

    def handle_command(args_a=nil, reply)
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
            reply_text = "Cool, booking date #{@date.full_date_string} ... "
            msg_h = @api_handler.book_date(@date)
            reply_text << "\n\n " + msg_h.values.first
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
          @state = :init
          msg_h = @api_handler.book_date(@date)
          reply_text << "\n\n #{@date.full_date_string} "
          reply_text << msg_h.values.first if msg_h
        else
          reply_text = "Wrong format, try again"
        end
      end

      force_reply = @state != :init
      {reply: reply_text, force_reply: force_reply}
    end


    def cancel
      @state = :init
      @date = nil
    end
  end
end
