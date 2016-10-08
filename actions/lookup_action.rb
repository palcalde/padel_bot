module Canal
  class LookupAction
    def initialize(network_manager)
      @network_manager = network_manager
    end

    def handle_command(args_a=nil, reply)
      payload = Payload.get_sample_payload
      resp = @network_manager.available(payload)
      if resp
        reply.text = "Available! book it here: " + resp.requested_url
      else
        reply.text = "Network problems.. maybe try to log in first?"
      end
      { reply: reply, force_reply: false }
    end

    def cancel
    end
  end
end
