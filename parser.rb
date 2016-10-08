class Parser
  class << self
    # date is a string separated by /
    # time is a string separated by :
    def parse_date(date, time = "")
      return unless date && time
      date_a = date.split('/')
      time_a = time.split(':')
      p "parsing date #{date_a} and time #{time_a}"
      day = date_a[0]
      month = date_a[1]
      year = date_a[2].length == 2 ? "20" + date_a[2] : date_a[2]
      hours = time_a[0]
      minutes = time_a[1]
      p "#{year}#{month}#{day}#{hours}#{minutes}"
      begin
        date = Time.local(year, month, day, hours, minutes)
        valid_d = date.strftime("%d").to_i == day.to_i
        valid_mon = date.strftime("%m").to_i == month.to_i
        valid_y = date.strftime("%Y").to_i == year.to_i
        valid_h = date.strftime("%H").to_i == hours.to_i
        valid_min = date.strftime("%M").to_i == minutes.to_i

        valid_date = date_a ? valid_d && valid_mon && valid_y : true
        valid_time = time_a ? valid_h && valid_min : true
        (valid_date && valid_time) ? date : nil
      rescue Exception => msg
        puts msg
        return nil
      end
    end
  end
end
