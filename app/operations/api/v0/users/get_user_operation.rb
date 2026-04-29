# frozen_string_literal: true

module Api::V0::Users
  class GetUserOperation < BaseOperation
    def call(current_user)
      @current_user = current_user

      Success(json_serialize)
    end

    private

    attr_reader :current_user

    def json_serialize
      {
        json: Api::V0::UserBlueprint.render_as_hash(current_user)
      }
    end
  end
end
