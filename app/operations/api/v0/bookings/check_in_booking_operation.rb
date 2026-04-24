# frozen_string_literal: true

module Api::V0::Bookings
  class CheckInBookingOperation < BaseOperation
    contract do
      params do
        required(:id).filled(:integer)
      end
    end

    def call(params, current_user)
      @params = params
      @current_user = current_user
      @booking = Booking.find_by(id: params[:id])

      return Failure(:not_found) unless booking
      return Failure(:forbidden) unless authorize?

      result = Bookings::CheckInService.call(booking: booking, checked_in_by: current_user)
      return Failure(result.error) unless result.success?

      @booking = result.data
      Success(booking: booking, json: serialize)
    end

    private

    attr_reader :params, :current_user, :booking

    def authorize?
      BookingPolicy.new(current_user, booking).check_in?
    end

    def serialize
      Api::V0::BookingBlueprint.render_as_hash(booking, view: :detailed)
    end
  end
end
