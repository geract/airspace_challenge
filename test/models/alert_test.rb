require "test_helper"

class AlertTest < ActiveSupport::TestCase
  test "raise_once! does not duplicate an open alert of the same kind" do
    shipment = create_shipment
    first = Alert.raise_once!(shipment, kind: "at_risk", message: "late")
    second = Alert.raise_once!(shipment, kind: "at_risk", message: "still late")

    assert_equal first, second
    assert_equal 1, shipment.alerts.count
  end

  test "raise_once! raises a new alert once the previous one is acknowledged" do
    shipment = create_shipment
    Alert.raise_once!(shipment, kind: "at_risk", message: "late").acknowledge!
    Alert.raise_once!(shipment, kind: "at_risk", message: "late again")

    assert_equal 2, shipment.alerts.count
  end
end
