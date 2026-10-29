class Shipment < ApplicationRecord
  STATUSES = %w[booked in_transit delivered cancelled].freeze

  belongs_to :flight
  has_many :alerts, dependent: :destroy

  validates :reference, :consignee, presence: true
  validates :reference, uniqueness: true
  validates :status, inclusion: { in: STATUSES }
  validates :last_mile_minutes, numericality: { greater_than_or_equal_to: 0 }
  validate :destination_time_zone_is_known

  # Shipments we still owe the customer. Delivered/cancelled ones are done.
  scope :active, -> { where(status: %w[booked in_transit]) }
  scope :due_on, ->(date) { where(deliver_by: date.all_day) }

  # When we expect it at the consignee's door. Nil if the flight is cancelled.
  def projected_delivery_at
    eta = flight.current_eta
    eta && eta + last_mile_minutes.minutes
  end

  def at_risk?
    flight.cancelled? || projected_delivery_at > deliver_by
  end

  # Nil when the flight is cancelled: there is no ETA to measure against.
  def minutes_late
    projected_delivery_at && ((projected_delivery_at - deliver_by) / 60).ceil
  end

  private

  def destination_time_zone_is_known
    return if ActiveSupport::TimeZone[destination_time_zone.to_s]

    errors.add(:destination_time_zone, "is not a known time zone")
  end
end
