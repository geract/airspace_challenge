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

  test "raises one at_risk alert per shipment made late, and only once per repeated update" do
    flight = create_flight(number: "AS1102", scheduled_arrival_at: Time.zone.parse("2026-10-28 10:00"))
    late = create_shipment(flight: flight, last_mile_minutes: 30, deliver_by: Time.zone.parse("2026-10-28 11:00"))
    fine = create_shipment(flight: flight, last_mile_minutes: 30, deliver_by: Time.zone.parse("2026-10-28 14:00"))
    payload = { "flight_number" => "AS1102", "status" => "delayed", "estimated_arrival_at" => "2026-10-28T11:00:00-07:00" }

    FlightUpdates::Apply.call(payload)
    FlightUpdates::Apply.call(payload)

    assert_equal 1, late.alerts.where(kind: "at_risk").count
    assert_equal 0, fine.alerts.count
    assert_includes late.alerts.first.message, late.reference
  end

  test "a cancelled flight puts every active shipment at risk" do
    flight = create_flight(number: "AS1102")
    active = create_shipment(flight: flight, status: "in_transit")
    done = create_shipment(flight: flight, status: "delivered")

    FlightUpdates::Apply.call("flight_number" => "AS1102", "status" => "cancelled", "estimated_arrival_at" => nil)

    assert_equal 1, active.alerts.where(kind: "at_risk").count
    assert_equal 0, done.alerts.count
  end
end
