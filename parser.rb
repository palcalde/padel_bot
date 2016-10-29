class DateParser
  class << self
    # date is a string separated by /
    # time is a string separated by :
    # Returns a Time object with date and time set
    def parse_date_and_time(date_str, time_str = "")
      return unless date_str && time_str
      date_a = date_str.split('/')
      time_a = time_str.split(':')
      p "parsing date #{date_a} and time #{time_a}"
      day = date_a[0] || Time.new.strftime("%d")
      month = date_a[1] || Time.new.strftime("%m")
      year = date_a[2] || Time.new.strftime("%Y")
      year = "20" + year if year.length == 2
      hours = time_a[0] || '00'
      minutes = time_a[1] || '00'
      p "#{year}#{month}#{day}#{hours}#{minutes}"
      begin
        parsed_time = Time.local(year, month, day, hours, minutes)
        parsed_date = parsed_time.to_date
        parsed_date = parsed_date.next_month if Date.today > parsed_date
        Time.local(parsed_date.year, parsed_date.month, parsed_date.day, hours, minutes)
      rescue Exception => msg
        puts msg
        return nil
      end
    end
  end
end
