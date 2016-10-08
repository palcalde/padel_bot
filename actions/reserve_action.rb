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
          @date = Parser.parse_date(args_a[0], args_a[1])
          if @date
            reply.text = "Cool, booking date #{date}"
          else
            reply.text = "Wrong format, try again"
          end
        end
      when :date
        puts "getting date"
        date = args_a[0]
        date = Parser.parse_date(args_a[0])
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
        @date = Parser.parse_date(@date, time)
        puts "date with time is #{@date}"
        if @date
          @state = :init
          reply.text = "Cool, booking date #{@date}"
        else
          reply.text = "Wrong format, try again"
        end
      end

      force_reply = @state != :init
      {reply: reply, force_reply: force_reply}
    end

    def cancel
      @state = :init
      @date = nil
    end
  end
end
