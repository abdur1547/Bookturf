# frozen_string_literal: true

module Api::V0::Roles
  class DeleteRoleOperation < BaseOperation
    contract do
      params do
        required(:id).filled(:string)
      end
    end

    def call(params, current_user)
      @params = params
      @current_user = current_user
      @role_id = params[:id]

      @role = Role.find_by(id: @role_id)
      return Failure(:not_found) unless @role

      return Failure(:forbidden) unless authorize

      result = Roles::DeleteService.call(
        role: @role,
        deleted_by: current_user
      )
      return Failure(result.error) unless result.success?
      json_data = { message: "Role deleted successfully" }
      Success(role: @role, json: json_data)
    end

    private

    attr_reader :role_id, :current_user, :role

    def authorize
      RolePolicy.new(current_user, role).destroy?
    end
  end
end
