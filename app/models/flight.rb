class Flight < ApplicationRecord
  STATUSES = %w[scheduled delayed cancelled landed].freeze

  has_many :shipments

  validates :number, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }

  # Best current estimate of arrival. Nil when the flight is cancelled.
  def current_eta
    return nil if cancelled?

    estimated_arrival_at || scheduled_arrival_at
  end

  def cancelled?
    status == "cancelled"
  end
end
