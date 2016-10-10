# Excon doesn't seem to provide an accessor to get the full url of the response,
# lets add one and let network_manager set it
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

class Time
  def year_month_day
    self.strftime("%Y-%m-%dT00:00:00")
  end

  def minutes_seconds
    self.strftime("%H:%M")
  end

  def full_date_string
    self.strftime("%d-%m-%Y at %H:%M")
  end
end
