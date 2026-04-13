# frozen_string_literal: true

module Bookings
  class CreateService < BaseService
    def call(params:)
      booking = Booking.new(params)

      unless booking.save
        return failure(booking.errors.full_messages)
      end

      success(booking)
    rescue StandardError => e
      failure("Failed to create booking: #{e.message}")
    end
  end
end
