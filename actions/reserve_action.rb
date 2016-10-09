module Canal
  class ReserveAction
    def initialize(network_manager)
      @network_manager = network_manager
      @date = nil
      @state = :init
    end

    def handle_command(args_a=nil, reply)
      return {} unless args_a && reply
      puts "args are #{args_a}"
      case @state
      when :init
        if args_a.count == 0
          @state = :date
          reply.text = "Ok! give me a date!"
        elsif args_a.count == 2
          @date = Parser.parse_date_and_time(args_a[0], args_a[1])
          if @date
            reply.text = "Cool, booking date #{@date.full_date_string} ... "
            book_date(@date, reply)
          else
            reply.text = "Wrong format, try again"
          end
        end
      when :date
        puts "getting date"
        date = args_a[0]
        date = Parser.parse_date_and_time(args_a[0])
        puts "date is #{date}"

        if date
          @date = args_a[0]
          @state = :time
          reply.text = "Ok.. what time?"
        else
          reply.text = "Wrong format, try again"
        end
      when :time
        time = args_a[0]
        @date = Parser.parse_date_and_time(@date, time)
        puts "date with time is #{@date}"
        if @date
          @state = :init
          reply.text = "Cool, booking date #{@date.full_date_string} ..."
          book_date(@date, reply)
        else
          reply.text = "Wrong format, try again"
        end
      end

      force_reply = @state != :init
      {reply: reply, force_reply: force_reply}
    end

    def book_date(date, reply)
      return unless date
      if date.to_date < Date.today
        reply.text = "\n\n Whoops! Date should be after today"
      else
        resp = @network_manager.available(date)
        if resp.status == 200
          reply.text << "\n\nAvailable! book it here: " + resp.requested_url
        elsif resp.status == 303
          if date.to_date >= Date.today.next_day(7)
            reply.text = "\n\n I can only book for the next 6 days. Maybe set a reminder?"
          else
            reply.text << "\n\nNot available :("
          end
        elsif resp == nil
          reply.text << "\n\nNetwork problems.. maybe try to log in first?"
        end
      end
    end

    def cancel
      @state = :init
      @date = nil
    end
  end
end
