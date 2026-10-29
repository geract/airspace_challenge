class DashboardController < ApplicationController
  def show
    @date = Date.current
    @shipments = Shipment.active.due_on(@date).order(:deliver_by)
    @at_risk, @on_track = @shipments.partition(&:at_risk?)
  end
end
