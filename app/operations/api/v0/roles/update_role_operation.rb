# frozen_string_literal: true

module Api::V0::Roles
  class UpdateRoleOperation < BaseOperation
    contract do
      params do
        required(:id).filled(:string)
        required(:role).hash do
          optional(:name).filled(:string)
          optional(:description).maybe(:string)
          optional(:permission_ids).maybe(:array)
        end
      end
    end

    def call(params, current_user)
      @params = params
      @current_user = current_user
      @role_id = params[:id]

      @role = Role.find_by(id: @role_id)
      return Failure(error: "Role not found") unless @role

      return Failure(:unauthorized) unless authorize

      result = Roles::UpdateService.call(
        role: @role,
        params: params[:role],
        updated_by: current_user
      )

      return Failure(errors: result.error) unless result.success?

      @role = result.data
      @role.reload
      json_data = serialize
      Success(role: @role, json: json_data)
    end

    private

    attr_reader :params, :current_user, :role_id, :role

    def authorize
      RolePolicy.new(current_user, role).update?
    end

    def serialize
      Api::V0::RoleBlueprint.render_as_hash(role, view: :detailed)
    end
  end
end
