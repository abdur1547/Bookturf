# frozen_string_literal: true

module Api::V0::Bookings
  class DeleteBookingOperation < BaseOperation
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

      result = Bookings::DeleteService.call(booking: booking)
      return Failure(error: result.error) unless result.success?

      Success(booking: booking, json: { message: "Booking deleted successfully" })
    end

    private

    attr_reader :params, :current_user, :booking

    def authorize?
      BookingPolicy.new(current_user, booking).destroy?
    end
  end
end
