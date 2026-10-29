require "test_helper"

class FlightUpdates::ApplyTest < ActiveSupport::TestCase
  test "updates status and estimated arrival" do
    flight = create_flight(number: "AS1102")
    eta = 3.hours.from_now.change(usec: 0)

    FlightUpdates::Apply.call("flight_number" => "AS1102", "status" => "delayed", "estimated_arrival_at" => eta.iso8601)

    flight.reload
    assert_equal "delayed", flight.status
    assert_equal eta, flight.estimated_arrival_at
  end

  test "raises for an unknown flight" do
    assert_raises(ActiveRecord::RecordNotFound) do
      FlightUpdates::Apply.call("flight_number" => "NOPE1", "status" => "delayed")
    end
  end
end
