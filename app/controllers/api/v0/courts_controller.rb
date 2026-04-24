# frozen_string_literal: true

module Api::V0
  class CourtsController < ApiController
    skip_before_action :authenticate_user!, only: %i[index show]

    # GET /api/v0/courts
    def index
      result = Api::V0::Courts::ListCourtsOperation.call(params.to_unsafe_h, current_user)

      handle_operation_response(result)
    end

    # GET /api/v0/courts/:id
    def show
      result = Api::V0::Courts::GetCourtOperation.call(params.to_unsafe_h, current_user)

      handle_operation_response(result)
    end

    # POST /api/v0/courts
    def create
      result = Api::V0::Courts::CreateCourtOperation.call(params.to_unsafe_h, current_user)

      handle_operation_response(result, :created)
    end

    # PATCH/PUT /api/v0/courts/:id
    def update
      result = Api::V0::Courts::UpdateCourtOperation.call(params.to_unsafe_h, current_user)

      handle_operation_response(result)
    end

    # PATCH /api/v0/courts/:id/reorder
    def reorder
      result = Api::V0::Courts::ReorderCourtOperation.call(params.to_unsafe_h, current_user)

      handle_operation_response(result)
    end

    # DELETE /api/v0/courts/:id
    def destroy
      result = Api::V0::Courts::DeleteCourtOperation.call(params.to_unsafe_h, current_user)

      handle_operation_response(result)
    end
  end
end
