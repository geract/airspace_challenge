class DashboardController < ApplicationController
  def show
    @date = Date.current
    @shipments = Shipment.active.due_on(@date).order(:deliver_by)
  end
end
