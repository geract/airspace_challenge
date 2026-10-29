# Stand-in for the real paging integration. Every call wakes a human up.
class OpsPager
  def self.notify(alert)
    Rails.logger.warn("[OPS PAGE] #{alert.shipment.reference} #{alert.kind}: #{alert.message}")
  end
end
