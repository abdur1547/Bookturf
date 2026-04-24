# frozen_string_literal: true

module Api::V0::Roles
  class GetRoleOperation < BaseOperation
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

      json_data = serialize
      Success(role: @role, json: json_data)
    end

    private

    attr_reader :role_id, :current_user, :role

    def authorize
      RolePolicy.new(current_user, role).show?
    end

    def serialize
      Api::V0::RoleBlueprint.render_as_hash(role, view: :detailed)
    end
  end
end
