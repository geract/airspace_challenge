module Api
  class FlightUpdatesController < ActionController::API
    def create
      flight = FlightUpdates::Apply.call(update_params)
      render json: { flight: flight.number, status: flight.status }
    rescue ActiveRecord::RecordNotFound
      render json: { error: "unknown flight" }, status: :not_found
    rescue ActiveRecord::RecordInvalid, ActionController::ParameterMissing, KeyError => e
      render json: { error: e.message }, status: 422
    end

    private

    def update_params
      params.require(:flight_update)
            .permit(:flight_number, :status, :estimated_arrival_at)
            .to_h
    end
  end
end
