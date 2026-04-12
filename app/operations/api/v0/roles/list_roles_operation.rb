# frozen_string_literal: true

module Api::V0::Roles
  class ListRolesOperation < BaseOperation
    contract do
      params do
        optional(:type).maybe(:string)
      end
    end

    def call(params, current_user)
      @params = params
      @current_user = current_user

      return Failure(:unauthorized) unless authorize?

      @roles = filter_roles(params)
      @roles = sort_roles(@roles, params[:sort] || "name")
      json_data = serialize
      Success(roles: @roles, json: json_data)
    end

    private

    attr_reader :params, :current_user, :roles

    def authorize?
      RolePolicy.new(current_user, Role).index?
    end

    def filter_roles(params)
      roles = Role.all

      if params[:type].present?
        case params[:type]
        when "system"
          roles = roles.system_roles
        when "custom"
          roles = roles.custom_roles
        end
      end

      roles
    end

    def sort_roles(roles, sort_field)
      case sort_field
      when "name"
        roles.alphabetical
      when "created_at"
        roles.order(created_at: :desc)
      else
        roles.alphabetical
      end
    end

    def serialize
      Api::V0::RoleBlueprint.render_as_hash(roles, view: :list)
    end
  end
end
