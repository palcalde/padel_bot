module Canal
  class AddResultAction
    def initialize(api_handler)
      @api_handler = api_handler
    end

    def get_results
      filename = 'results.json'
      if !File.file?(filename)
        File.open(filename,"w") {|f| f.write("{}") }
        nil
      else
        file = File.read(filename)
        JSON.parse(file)
      end
    end

    def handle_command(args_a=[], reply)
      @results = get_results || Hash.new
      reply_text = ""
      p "args_a.count #{args_a.count} arg 1 is #{args_a[1]}"
      if args_a.count == 2 && args_a[1] == 'delete'
        p "deleting"
        date = Date.parse(args_a[0]).to_time
        p "date is #{date.date_string}"
        @results.delete(date.date_string)
        p "results are #{@results}"
        File.open("results.json","w") do |f|
          f.write(@results.to_json)
        end
        reply_text << "Result deleted for date: #{date.date_string}"
      elsif args_a.count == 3
        first_team = args_a[1]
        second_team = args_a[2]
        begin
          date = Date.parse(args_a[0]).to_time
        rescue
        end
        if date && valid_params(first_team, second_team)
          p "date is #{date.date_string}"
          @results[date.date_string] = "#{first_team.upcase} #{second_team.upcase}"
          File.open("results.json","w") do |f|
            f.write(@results.to_json)
          end
          reply_text << "Result added: #{date.date_string} #{@results[date.date_string]}"
        else
          reply_text = "Wrong format"
        end
      elsif args_a.count == 1
        # month = args_a[0]
      end
      {reply: reply_text, force_reply: false}
    end

    def valid_params(first_team, second_team)
      first_team.split('-').count == 2 && second_team.split('-').count == 2
    end

    def cancel
    end
  end
end
