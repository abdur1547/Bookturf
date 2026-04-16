# frozen_string_literal: true

module Api::V0::Users
  class DeleteUserOperation < BaseOperation
    contract do
      params do
        required(:password).filled(:string)
      end
    end

    def call(params, user_id, current_user)
      @params = params
      @user_id = user_id
      @current_user = current_user

      yield authorize
      yield find_user
      yield validate_password
      yield delete_user
      success_response
    end

    private

    attr_reader :params, :user_id, :current_user, :user

    def authorize
      return Success() if current_user.id.to_s == user_id.to_s

      Failure(:unauthorized)
    end

    def find_user
      @user = User.find(user_id)
      Success(user)
    rescue ActiveRecord::RecordNotFound
      Failure({ id: [ "User not found" ] })
    end

    def validate_password
      return Success() if user.authenticate(params[:password])

      Failure({ password: [ "Password is incorrect" ] })
    end

    def delete_user
      user.destroy
      Success()
    rescue => e
      Failure({ base: [ "Failed to delete account: #{e.message}" ] })
    end

    def success_response
      {
        json: {
          message: "Account deleted successfully"
        }
      }
    end
  end
end
