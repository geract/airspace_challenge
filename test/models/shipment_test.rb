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

  test "at_risk? when projected delivery is after deliver_by" do
    flight = create_flight(scheduled_arrival_at: Time.zone.parse("2026-10-28 10:00"))
    shipment = create_shipment(flight: flight, last_mile_minutes: 30, deliver_by: Time.zone.parse("2026-10-28 10:20"))

    assert shipment.at_risk?
    assert_equal 10, shipment.minutes_late
  end

  test "not at_risk? when projected delivery is on or before deliver_by" do
    flight = create_flight(scheduled_arrival_at: Time.zone.parse("2026-10-28 10:00"))
    on_time = create_shipment(flight: flight, last_mile_minutes: 30, deliver_by: Time.zone.parse("2026-10-28 10:30"))
    early = create_shipment(flight: flight, last_mile_minutes: 30, deliver_by: Time.zone.parse("2026-10-28 11:00"))

    assert_not on_time.at_risk?
    assert_not early.at_risk?
  end

  test "at_risk? when the flight is cancelled, with no minutes_late" do
    shipment = create_shipment(flight: create_flight(status: "cancelled"))

    assert shipment.at_risk?
    assert_nil shipment.minutes_late
  end
end
