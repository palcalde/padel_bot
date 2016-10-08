module Canal
  class LookupAction
    def initialize(network_manager)
      @network_manager = network_manager
    end

    def handle_command(args_a=nil, reply)
      resp = @network_manager.available(Time.now)
      if resp.status == 200
        reply.text = "Available! book it here: " + resp.requested_url
      elsif response.status == 303
        reply.text = "Not available :("
      elsif resp == nil
        reply.text = "Network problems.. maybe try to log in first?"
      end
      { reply: reply, force_reply: false }
    end

    def cancel
    end
  end
end
