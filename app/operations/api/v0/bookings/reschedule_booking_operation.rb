# frozen_string_literal: true

module Api::V0::Bookings
  class RescheduleBookingOperation < BaseOperation
    contract do
      params do
        required(:id).filled(:integer)
        required(:booking).hash do
          optional(:court_id).maybe(:integer)
          required(:start_time).filled(:string)
          required(:end_time).filled(:string)
        end
      end
    end

    def call(params, current_user)
      @params = params
      @current_user = current_user
      @booking = Booking.find_by(id: params[:id])

      return Failure(error: "Booking not found") unless booking
      return Failure(:unauthorized) unless authorize?

      result = Bookings::RescheduleService.call(booking: booking, params: params[:booking])
      return Failure(error: result.error) unless result.success?

      @booking = result.data
      Success(booking: booking, json: serialize)
    end

    private

    attr_reader :params, :current_user, :booking

    def authorize?
      BookingPolicy.new(current_user, booking).reschedule?
    end

    def serialize
      Api::V0::BookingBlueprint.render_as_hash(booking, view: :detailed)
    end
  end
end
