class Alert < ApplicationRecord
  KINDS = %w[at_risk missed_handoff customs_hold].freeze

  belongs_to :shipment

  validates :kind, inclusion: { in: KINDS }
  validates :message, presence: true

  scope :unacknowledged, -> { where(acknowledged_at: nil) }

  after_create_commit -> { OpsPager.notify(self) }

  # Every new alert pages someone. Use this rather than create! so that a
  # repeated event doesn't page ops again while the first alert is still open.
  def self.raise_once!(shipment, kind:, message:)
    unacknowledged.find_by(shipment: shipment, kind: kind) ||
      create!(shipment: shipment, kind: kind, message: message)
  end

  def acknowledge!
    update!(acknowledged_at: Time.current)
  end
end
