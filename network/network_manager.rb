require 'excon'
require 'virtus'
require 'json'
require 'base64'

module Canal::Network
  class NetworkManager
    AUTH_COOKIE = "sfxSession"

    def initialize(opts = {})
      p "initialized canal network manager"
      @logger = opts[:logger]
      @connection = Excon.new('https://www.mypadel.com', proxy: opts[:proxy])
      @cookies = Hash.new
      log_in
    end

    def log_in
      resp = @connection.post(path: "/booking/login",
                       body: URI.encode_www_form({email: ENV['PADEL_USERNAME'], password: ENV['PADEL_PASSWORD']}))
      parse_cookies(resp)
      resp
    end

    def parse_cookies(resp)
      @cookies = resp[:cookies].map { |c|
        cookie = c.split(';').first.split('=')[0]
        value = c.split(';').first.split('=')[1]
        {cookie => value}
      }.inject(:merge)
    end

    def available(query)
      return unless query && @cookies[AUTH_COOKIE]
      p "query is #{query}"
      encoded_query = Base64.strict_encode64(query.to_json)
      path = "/booking/resumen"
      query = { m: encoded_query }
      cookie = AUTH_COOKIE + '=' + @cookies[AUTH_COOKIE]
      res = @connection.get(headers: {'Cookie' => cookie}, path: path, query: query)
      params = { :path => path, :query => query }
      res.requested_url = @connection.request_uri(@connection.data.merge(params))
      res
    end
  end
end
