# frozen_string_literal: true

module Bookings
  class CompleteService < BaseService
    def call(booking:)
      unless booking.confirmed?
        return failure("Only confirmed bookings can be completed")
      end

      booking.complete!
      success(booking)
    rescue StandardError => e
      failure("Failed to complete booking: #{e.message}")
    end
  end
end
