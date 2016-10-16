module Canal
  class ApiHandler
    def initialize(opts = {})
      @network_manager = NetworkManager.new(proxy: opts[:proxy])
    end

    def book_date(date)
      return {} unless date
      if date.to_date < Date.today
          {error: "Whoops! Date should be after today"}
      else
        resp = @network_manager.available(date)
        if resp.status == 200
          {ok: "[Available!](#{resp.requested_url})"}
        elsif resp.status == 303
          p "comparing #{date.to_date} with #{Date.today.next_day(7)}"
          if date.to_date >= Date.today.next_day(7)
            {error: "Can't check that date yet. Maybe set a reminder?"}
          else
            {error:"Not available :("}
          end
        else
            {error:"Network problems :/"}
        end
      end
    end
  end
end
