module Excon
  class Response
    def requested_url=(url)
      @requested_url = url
    end

    def requested_url
      @requested_url || ""
    end
  end
end
