# frozen_string_literal: true

module Bookings
  class CheckInService < BaseService
    def call(booking:, checked_in_by:)
      unless booking.confirmed?
        return failure("Only confirmed bookings can be checked in")
      end

      booking.check_in!(checked_in_by: checked_in_by)
      success(booking)
    rescue StandardError => e
      failure("Failed to check in booking: #{e.message}")
    end
  end
end
