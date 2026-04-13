# frozen_string_literal: true

module Api::V0::Courts
  class CreateCourtOperation < BaseOperation
    contract do
      params do
        required(:court).hash do
          required(:venue_id).filled(:integer)
          required(:court_type_id).filled(:integer)
          required(:name).filled(:string)
          optional(:description).maybe(:string)
          optional(:is_active).maybe(:bool)
          optional(:display_order).maybe(:integer)
        end
      end
    end

    def call(params, current_user)
      @params = params
      @current_user = current_user
      court_params = params[:court]

      @venue = Venue.find_by(id: court_params[:venue_id])
      return Failure(error: "Venue not found") unless @venue
      return Failure(:unauthorized) unless authorize

      result = Courts::CreateService.call(params: court_params)
      return Failure(error: result.error) unless result.success?

      @court = result.data
      json_data = serialize
      Success(court: @court, json: json_data)
    end

    private

    attr_reader :params, :current_user, :court, :venue

    def authorize
      VenuePolicy.new(current_user, venue).update?
    end

    def serialize
      Api::V0::CourtBlueprint.render_as_hash(court, view: :detailed)
    end
  end
end
