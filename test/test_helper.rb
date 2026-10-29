ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module Builders
  def create_flight(**attrs)
    Flight.create!({
      number: "XX#{SecureRandom.hex(3)}", origin: "SEA", destination: "LAX",
      scheduled_arrival_at: 2.hours.from_now
    }.merge(attrs))
  end

  def create_shipment(**attrs)
    Shipment.create!({
      reference: "T-#{SecureRandom.hex(3)}", consignee: "Test Co",
      flight: attrs[:flight] || create_flight, deliver_by: 4.hours.from_now,
      last_mile_minutes: 45, destination_time_zone: "America/Los_Angeles", status: "booked"
    }.merge(attrs))
  end
end

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    include Builders
  end
end
