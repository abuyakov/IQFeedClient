# frozen_string_literal: true

module Dtn
  module Requests
    module Historical
      # Tick days requests
      class TickDay < Base
        TEMPLATE =
          "HTD,%<symbol>s,%<days>s,%<max_datapoints>d,%<begin_datetime>s,%<end_datetime>s," \
          "%<data_direction>d,%<request_id>d,%<datapoints_per_send>d\r\n"

        # Get historical tick day data
        # NOTE: Unfortunately I constantly get an empty response with this and
        #       more information about this data point needed.
        #
        # Example message
        #
        #   HTD,[Symbol],[Days],[MaxDatapoints],[BeginFilterTime],[EndFilterTime],[DataDirection],\
        #   [RequestID],[DatapointsPerSend]<CR><LF>
        #
        # @returns Integer request_id
        def call(symbol:, days:, begin_datetime:, end_datetime:, **options)
          self.combined_options = defaults(**options).merge({
                                                              symbol: symbol.to_s.upcase,
                                                              days: days.to_i > MAX_INT16 ? MAX_INT16 : days,
                                                              begin_datetime: begin_datetime.strftime("%Y%m%d %H%M%S"),
                                                              end_datetime: end_datetime.strftime("%Y%m%d %H%M%S")
                                                            })

          socket.print format(TEMPLATE, combined_options)
          request_id
        end
      end
    end
  end
end
