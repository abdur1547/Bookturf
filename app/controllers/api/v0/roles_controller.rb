# frozen_string_literal: true

module Api::V0
  class RolesController < ApiController
    # GET /api/v0/roles
    def index
      result = Api::V0::Roles::ListRolesOperation.call(params.to_unsafe_h, current_user)

      handle_operation_response(result)
    end

    # GET /api/v0/roles/:id
    def show
      result = Api::V0::Roles::GetRoleOperation.call(params.to_unsafe_h, current_user)

      handle_operation_response(result)
    end

    # POST /api/v0/roles
    def create
      result = Api::V0::Roles::CreateRoleOperation.call(params.to_unsafe_h, current_user)

      handle_operation_response(result, :created)
    end

    # PATCH/PUT /api/v0/roles/:id
    def update
      result = Api::V0::Roles::UpdateRoleOperation.call(params.to_unsafe_h, current_user)

      handle_operation_response(result)
    end

    # DELETE /api/v0/roles/:id
    def destroy
      result = Api::V0::Roles::DeleteRoleOperation.call(params.to_unsafe_h, current_user)

      handle_operation_response(result)
    end
  end
end
