# frozen_string_literal: true

module Api::V0::Bookings
  class CheckAvailabilityOperation < BaseOperation
    contract do
      params do
        required(:availability).hash do
          required(:court_id).filled(:integer)
          required(:start_time).filled(:string)
          required(:end_time).filled(:string)
          optional(:exclude_booking_id).maybe(:integer)
        end
      end
    end

    def call(params, current_user)
      @params = params
      @current_user = current_user

      return Failure(:forbidden) unless authorize?

      court = Court.find_by(id: params[:availability][:court_id])
      return Failure(:not_found) unless court

      start_time = parse_datetime(params[:availability][:start_time])
      end_time = parse_datetime(params[:availability][:end_time])
      return Failure("Invalid availability window") unless start_time && end_time

      available = Booking.slot_available?(court, start_time, end_time, exclude_booking_id: params[:availability][:exclude_booking_id])

      Success(json: { available: available })
    end

    private

    attr_reader :params, :current_user

    def authorize?
      current_user.present?
    end

    def parse_datetime(value)
      Time.zone.parse(value)
    rescue ArgumentError, TypeError
      nil
    end
  end
end
