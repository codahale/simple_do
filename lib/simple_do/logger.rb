module DataObjects
  class Simple
    class Logger

      def initialize(logger)
        @logger = logger
      end

      def log(query, variables)
        @logger.debug(format(query, variables))
      end

    private

      def format(query, variables)
        message_color, dump_color = get_colors
        log_entry = "  \e[#{message_color}mSQL:\e[0m   "
        log_entry << "\e[#{dump_color}m%s\e[0m" % format_query(query, variables)
        return log_entry
      end

      def get_colors
        @row_even = !@row_even
        return @row_even ? ["4;36;1", "0;1"] : ["4;35;1", "0"]
      end

      def format_query(query, variables)
        log_entry = query.gsub(/[\s]+/i, " ")
        if variables.any?
          log_entry << " \e[0;33;1m#{variables.inspect}\e[0m"
        end
        return log_entry
      end

    end
  end
end