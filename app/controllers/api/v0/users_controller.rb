# frozen_string_literal: true

module Api::V0
  class UsersController < ApiController
    def show
      result = Api::V0::Users::GetUserOperation.call(current_user)
      handle_operation_response(result)
    end

    def update
      result = Api::V0::Users::UpdateUserOperation.call(params.to_unsafe_h, params[:id], current_user)
      handle_operation_response(result)
    end

    def upload_avatar
      result = Api::V0::Users::UploadAvatarOperation.call(params, current_user)
      handle_operation_response(result)
    end

    def change_password
      result = Api::V0::Users::ChangePasswordOperation.call(params.to_unsafe_h, params[:id], current_user)
      handle_operation_response(result)
    end

    def destroy
      result = Api::V0::Users::DeleteUserOperation.call(params.to_unsafe_h, params[:id], current_user)
      handle_operation_response(result)
    end
  end
end
