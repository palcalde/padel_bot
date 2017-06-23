module Canal
  class ApiHandler
    def initialize(opts = {})
      @network_manager = NetworkManager.new(proxy: opts[:proxy])
    end

    def check_date(date)
      p "1111"
      return {error: "Bot not logged in"} unless @network_manager.authorized?

      p "2222"

      return {} unless date

      p "3333"

      if date.to_date < Date.today
          {error: "Whoops! Date should be after today"}
      else
        resp = @network_manager.available(date)
        if resp.status == 200
          {ok: "[Available!](#{resp.requested_url})", resp: resp}
        elsif resp.status == 303
          p "comparing #{date.to_date} with #{Date.today.next_day(7)}"
          if date.to_date >= Date.today.next_day(7)
            {error: "Can't check that date yet. Maybe set a reminder?", resp: resp}
          else
            {error:"Not available :(", resp: resp}
          end
        else
            {error:"Network problems :/", resp: resp}
        end
      end
    end

    def reserve_date(date)
      return { error: "Bot not logged in" } unless @network_manager.authorized?

      return {} unless date

      avail = check_date(date)
      return avail unless avail[:ok]

      resp = avail[:resp]
      found_s = resp.body.scan(/(\{\s*"paymentMethods"\s*:\s*(.+?)\s*,(.+?),\s*"idType"\s*:\s*(.+?)\s*\})/)
      payment_info = found_s.first.first if (found_s && !found_s.empty?)
      if payment_info
        JSON.parse(payment_info).tap do |payment_h|
          if payment_h
            reserve_resp = @network_manager.reserve(date, payment_h)
            p ""
            if reserve_resp.nil?
                return {error: "\n\n Can't book, time to put more money?"}
            elsif reserve_resp.status == 303
              return {ok:"Booked, check your email!", resp: resp}
            else
              if !payment_h['paymentMethods'].empty?
                return {error: "couldn't be booked. Maybe not enough money? #{payment_h['paymentMethods'].first['name']}"}
              else
                return {error: "Couldn't book, sorry :("}
              end
            end
          else
            return {error:"Whoops, some problem occured", resp: resp}
          end
        end
      else
        return {error:"Whoops, some problem occured", resp: resp}
      end
    end
  end
end
