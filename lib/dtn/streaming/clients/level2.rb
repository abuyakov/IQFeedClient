# frozen_string_literal: true

module Dtn
  module Streaming
    module Clients
      # Provides a connection to IQFeed's Level2 socket.
      class Level2 < Client
        PORT = 9200

        SUPPORTED_MESSAGES = {
          "Z" => Messages::Level2::Level2Update, # Summary message, but it's actually the same
          "2" => Messages::Level2::Level2Update,
          "M" => Messages::Level2::MarketMakerName, # A Market Maker name OR order book level query response message.
          "S" => Messages::System::Generic,
          "T" => Messages::System::Timestamp,
          "n" => Messages::System::SymbolNotFound,
          "E" => Messages::System::Error
        }.freeze

        private

        def init_connection
          request.level2.connect
        end
      end
    end
  end
end
