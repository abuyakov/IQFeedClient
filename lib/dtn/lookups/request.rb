# frozen_string_literal: true

module Dtn
  module Lookups
    # Lookups are used to get historical data from IQFeed's lookup socket.
    # This class returns historical data as the return value from the function
    # used to request the data.
    #
    # Works synchronously
    #
    # For more details see:
    # www.iqfeed.net/dev/api/docs/HistoricalviaTCPIP.cfm
    class Request
      END_OF_MESSAGE_CHARACTERS = /!ENDMSG!/.freeze
      NO_DATA_CHARACTERS = /!NO_DATA!/.freeze
      SYNTAX_ERROR_CHARACTERS = /!SYNTAX_ERROR!/.freeze

      PORT = 9100

      include Dtn::Concerns::Id

      class << self
        def call(*args, **opts, &blk)
          new.call(*args, **opts, &blk)
        end
      end

      attr_accessor :combined_options

      # Initialize the request to api, should be used in children classes only
      #
      # @returns nil or request_id (Integer)
      def call(*, &blk)
        socket.print "#{format(self.class.const_get(:TEMPLATE), combined_options)}\r\n"

        pull_socket(&blk)

        return result_accumulator unless block_given?
      end

      private

      def pull_socket(&blk)
        catch(:pull_termination) do
          while (line = socket.gets)
            process_line(line: line, &blk)
          end
        end
      end

      def process_line(line:)
        message = engine_klass_picker(line).parse(line: line, request: self)
        throw(:pull_termination) if message.termination?

        block_given? ? yield(message) : result_accumulator << message
      end

      def result_accumulator
        @result_accumulator ||= []
      end

      def engine_klass_picker(line)
        /^(\d+,)?(.+)/ =~ line
        payload = Regexp.last_match(2)
        case payload
        when END_OF_MESSAGE_CHARACTERS then Messages::System::EndOfMessageCharacters
        when NO_DATA_CHARACTERS then Messages::System::NoDataCharacters
        when /^E,/, SYNTAX_ERROR_CHARACTERS then Messages::System::Error
        else expected_messages_class
        end
      end

      # This should contain expected class of the returning message.
      # Might be overwritten in child class
      #
      # @returns Class
      def expected_messages_class
        self.class.name.sub("Lookups", "Messages").constantize
      end

      def socket
        @socket ||= TCPSocket.open(Dtn.host, PORT)
      end

      def defaults(**options)
        {
          id: id
        }.merge(options)
      end
    end
  end
end
