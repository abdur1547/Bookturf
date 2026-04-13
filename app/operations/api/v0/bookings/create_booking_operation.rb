# frozen_string_literal: true

module Api::V0::Bookings
  class CreateBookingOperation < BaseOperation
    contract do
      params do
        required(:booking).hash do
          optional(:user_id).maybe(:integer)
          required(:court_id).filled(:integer)
          required(:start_time).filled(:string)
          required(:end_time).filled(:string)
          optional(:notes).maybe(:string)
          optional(:payment_method).maybe(:string)
          optional(:payment_status).maybe(:string)
        end
      end
    end

    def call(params, current_user)
      @params = params
      @current_user = current_user

      return Failure(:unauthorized) unless authorize?

      booking_params = params[:booking].dup
      booking_params[:user_id] ||= current_user.id
      booking_params[:created_by_id] = current_user.id

      result = Bookings::CreateService.call(params: booking_params)
      return Failure(error: result.error) unless result.success?

      @booking = result.data
      Success(booking: booking, json: serialize)
    end

    private

    attr_reader :params, :current_user, :booking

    def authorize?
      BookingPolicy.new(current_user, Booking).create?
    end

    def serialize
      Api::V0::BookingBlueprint.render_as_hash(booking, view: :detailed)
    end
  end
end
