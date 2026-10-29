module FlightUpdates
  # Applies one status update from the airline feed.
  #
  # payload: { "flight_number" => "AS1102", "status" => "delayed",
  #            "estimated_arrival_at" => "2026-10-28T14:05:00-07:00" }
  class Apply
    def self.call(payload)
      new(payload).call
    end

    def initialize(payload)
      @payload = payload
    end

    def call
      flight = Flight.find_by!(number: @payload.fetch("flight_number"))
      flight.update!(
        status: @payload.fetch("status"),
        estimated_arrival_at: parse_time(@payload["estimated_arrival_at"])
      )
      flight
    end

    private

    def parse_time(value)
      value.presence && Time.zone.parse(value)
    end
  end
end
