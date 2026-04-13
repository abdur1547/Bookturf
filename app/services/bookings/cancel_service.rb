# frozen_string_literal: true

module Bookings
  class CancelService < BaseService
    def call(booking:, cancelled_by:, reason: nil)
      unless booking.can_cancel?
        return failure("Booking cannot be cancelled")
      end

      booking.cancel!(reason: reason, cancelled_by: cancelled_by)
      success(booking)
    rescue StandardError => e
      failure("Failed to cancel booking: #{e.message}")
    end
  end
end
