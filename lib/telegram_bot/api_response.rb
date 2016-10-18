
# Override TelegramBot logic to trigger also a
# callback for each connection timeout
module TelegramBot
  class ApiResponse
    def initialize(res)
      @body = res.body
      if res.status == 200
        data = JSON.parse(body)
        @ok = data["ok"]
        @result = data["result"]
      else
        # data = JSON.parse(body)
        @ok = false
        @description = res.body
        @error_code = res.status
      end
    end
  end
end



