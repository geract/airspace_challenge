require "test_helper"

class ShipmentTest < ActiveSupport::TestCase
  test "projected delivery is flight ETA plus last mile" do
    flight = create_flight(scheduled_arrival_at: Time.zone.parse("2026-10-28 10:00"))
    shipment = create_shipment(flight: flight, last_mile_minutes: 30)

    assert_equal Time.zone.parse("2026-10-28 10:30"), shipment.projected_delivery_at
  end

  test "projected delivery uses the estimated arrival when present" do
    flight = create_flight(scheduled_arrival_at: Time.zone.parse("2026-10-28 10:00"),
                           estimated_arrival_at: Time.zone.parse("2026-10-28 11:00"))
    shipment = create_shipment(flight: flight, last_mile_minutes: 30)

    assert_equal Time.zone.parse("2026-10-28 11:30"), shipment.projected_delivery_at
  end

  test "projected delivery is nil when the flight is cancelled" do
    shipment = create_shipment(flight: create_flight(status: "cancelled"))

    assert_nil shipment.projected_delivery_at
  end

  test "active excludes delivered and cancelled shipments" do
    booked = create_shipment(status: "booked")
    in_transit = create_shipment(status: "in_transit")
    create_shipment(status: "delivered")
    create_shipment(status: "cancelled")

    assert_equal [booked, in_transit].sort_by(&:id), Shipment.active.order(:id).to_a
  end
end
