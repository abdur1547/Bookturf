# frozen_string_literal: true

module Api::V0::Courts
  class ReorderCourtOperation < BaseOperation
    contract do
      params do
        required(:id).filled
        required(:display_order).filled(:integer)
      end
    end

    def call(params, current_user)
      @params = params
      @current_user = current_user

      @court = find_court(params[:id])
      return Failure(error: :not_found) unless @court
      return Failure(:unauthorized) unless authorize

      result = Courts::ReorderService.call(court: @court, display_order: params[:display_order])
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
      {
        id: court.id,
        display_order: court.display_order
      }
    end
  end
end
