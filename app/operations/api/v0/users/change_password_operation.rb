# frozen_string_literal: true

module Api::V0::Users
  class ChangePasswordOperation < BaseOperation
    contract do
      params do
        required(:current_password).filled(:string)
        required(:password).filled(:string, min_size?: 8)
        required(:password_confirmation).filled(:string)
      end
    end

    def call(params, user_id, current_user)
      @params = params
      @user_id = user_id
      @current_user = current_user

      yield authorize
      yield find_user
      yield validate_current_password
      yield validate_password_match
      yield update_password
      success_response
    end

    private

    attr_reader :params, :user_id, :current_user, :user

    def authorize
      return Success() if current_user.id.to_s == user_id.to_s

      Failure(:forbidden)
    end

    def find_user
      @user = User.find(user_id)
      Success(user)
    rescue ActiveRecord::RecordNotFound
      Failure({ id: [ "User not found" ] })
    end

    def validate_current_password
      return Success() if user.authenticate(params[:current_password])

      Failure({ current_password: [ "Current password is incorrect" ] })
    end

    def validate_password_match
      return Success() if params[:password] == params[:password_confirmation]

      Failure({ password_confirmation: [ "Password confirmation does not match" ] })
    end

    def update_password
      unless user.update(password: params[:password], password_confirmation: params[:password_confirmation])
        return Failure(user.errors.to_h)
      end

      Success(user)
    end

    def success_response
      {
        json: {
          message: "Password changed successfully"
        }
      }
    end
  end
end
