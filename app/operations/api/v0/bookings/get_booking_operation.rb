# frozen_string_literal: true

module Api::V0::Bookings
  class GetBookingOperation < BaseOperation
    contract do
      params do
        required(:id).filled(:integer)
      end
    end

    def call(params, current_user)
      @params = params
      @current_user = current_user
      @booking = Booking.find_by(id: params[:id])

      return Failure(error: "Booking not found") unless booking
      return Failure(:unauthorized) unless authorize?

      Success(booking: booking, json: serialize)
    end

    private

    attr_reader :params, :current_user, :booking

    def authorize?
      BookingPolicy.new(current_user, booking).show?
    end

    def serialize
      Api::V0::BookingBlueprint.render_as_hash(booking, view: :detailed)
    end
  end
end
