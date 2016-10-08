module Canal
  class ReminderAction
    def initialize(network_manager)
      @network_manager = network_manager
      @date = nil
    end

    def handle_command(args_a=[], reply)
      if args_a.count == 0
        p "args are 0"
        if @date
          reply.text = "Your reminder is #{@date}"
        else
          reply.text = "No reminder yet, use /reminder to set up one"
        end
      elsif args_a.count == 2
        if @date = Parser.parse_date(args_a[0], args_a[1])
          reply.text = "Reminder setted to #{@date}"
        else
          reply.text = "Wrong date format, try again please"
        end
      else
        reply.text = "/reminder only accepts two params, date and time"
      end

      {reply: reply, force_reply: false}
    end

    def cancel
      @date = nil
    end
  end
end
