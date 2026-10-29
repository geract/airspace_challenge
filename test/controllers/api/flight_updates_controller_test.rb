require "test_helper"

class Api::FlightUpdatesControllerTest < ActionDispatch::IntegrationTest
  test "applies an update from the feed" do
    flight = create_flight(number: "AS1102")
    eta = 3.hours.from_now.change(usec: 0)

    post api_flight_updates_path,
         params: { flight_update: { flight_number: "AS1102", status: "delayed", estimated_arrival_at: eta.iso8601 } },
         as: :json

    assert_response :ok
    assert_equal "delayed", flight.reload.status
    assert_equal eta, flight.estimated_arrival_at
  end

  test "404s for an unknown flight" do
    post api_flight_updates_path,
         params: { flight_update: { flight_number: "NOPE1", status: "delayed" } },
         as: :json

    assert_response :not_found
  end
end
