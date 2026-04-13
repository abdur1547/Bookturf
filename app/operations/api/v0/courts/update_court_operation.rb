# frozen_string_literal: true

module Api::V0::Courts
  class UpdateCourtOperation < BaseOperation
    contract do
      params do
        required(:id).filled
        required(:court).hash do
          optional(:court_type_id).maybe(:integer)
          optional(:name).maybe(:string)
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

      @court = find_court(params[:id])
      return Failure(error: "Court not found") unless @court
      return Failure(:unauthorized) unless authorize

      result = Courts::UpdateService.call(court: @court, params: court_params)
      return Failure(error: result.error) unless result.success?

      @court = result.data
      json_data = serialize
      Success(court: @court, json: json_data)
    end

    private

    attr_reader :params, :current_user, :court

    def find_court(id)
      Court.find_by(id: id)
    end

    def authorize
      CourtPolicy.new(current_user, court).update?
    end

    def serialize
      Api::V0::CourtBlueprint.render_as_hash(court, view: :detailed)
    end
  end
end
