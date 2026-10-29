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
      flag_at_risk_shipments(flight)
      flight
    end

    private

    def flag_at_risk_shipments(flight)
      flight.shipments.active.select(&:at_risk?).each do |shipment|
        Alert.raise_once!(shipment, kind: "at_risk", message: at_risk_message(shipment))
      end
    end

    def at_risk_message(shipment)
      zone = shipment.destination_time_zone
      deliver_by = ApplicationController.helpers.local_time(shipment.deliver_by, zone)
      return "#{shipment.reference}: flight #{shipment.flight.number} cancelled, deliver-by #{deliver_by}" unless shipment.minutes_late

      projected = ApplicationController.helpers.local_time(shipment.projected_delivery_at, zone)
      "#{shipment.reference}: projected #{projected}, deliver-by #{deliver_by} (#{shipment.minutes_late} min late)"
    end

    def parse_time(value)
      value.presence && Time.zone.parse(value)
    end
  end
end
