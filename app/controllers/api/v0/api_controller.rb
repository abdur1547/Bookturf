# frozen_string_literal: true

module Api::V0
  class ApiController < ActionController::API
    include ErrorHandler
    include Pundit::Authorization

    before_action :authenticate_user!

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    attr_reader :current_user, :decoded_token

    private

    def authenticate_user!
      current_user, decoded_token = Jwt::Authenticator.call(
        headers: request.headers,
        cookies: request.cookies
      ).data

      @current_user ||= current_user
      @decoded_token ||= decoded_token
    end

    def handle_operation_response(result, success_status = :ok)
      if result.success
        render json: {
          success: true,
          data: result.value[:json]
        }, status: success_status
      else
        handle_operation_failure(result)
      end
    end

    def handle_operation_failure(result)
      errors = result.errors

      case errors
      when :unauthorized
        forbidden_response("You are not authorized to perform this action")
      else
        unprocessable_entity(errors)
      end
    end

    def user_not_authorized
      forbidden_response("You are not authorized to perform this action")
    end
  end
end
