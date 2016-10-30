module Canal
  class ShowResultsAction
    def initialize(api_handler)
      @api_handler = api_handler
    end

    def get_results
      filename = 'results.json'
      if !File.file?(filename)
        nil
      else
        file = File.read(filename)
        JSON.parse(file)
      end
    end

    def handle_command(args_a=[], reply)
      @results = get_results || Hash.new
      reply_text = ""
      if args_a.count == 0
        p "args are 0"
        @results.each do |key, value|
          reply_text << "#{key} #{value} \n\n"
        end
        reply_text << "No results to show" if reply_text.empty?
      elsif args_a.count == 1
        # month = args_a[0]
      end

      {reply: reply_text, force_reply: false}
    end

    def cancel
    end
  end
end
