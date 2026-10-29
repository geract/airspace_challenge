require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "at-risk shipments are listed in their own section above due today" do
    flight = create_flight(scheduled_arrival_at: 1.hour.from_now)
    late = create_shipment(flight: flight, last_mile_minutes: 60, deliver_by: 90.minutes.from_now)
    fine = create_shipment(flight: flight, last_mile_minutes: 10, deliver_by: 3.hours.from_now)

    get root_path

    assert_response :ok
    body = response.body
    assert_operator body.index("At risk"), :<, body.index(late.reference)
    assert_operator body.index(late.reference), :<, body.index("Due today")
    assert_operator body.index("Due today"), :<, body.index(fine.reference)
    assert_includes body, "30 min"
  end
end
