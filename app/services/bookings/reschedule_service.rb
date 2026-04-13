# frozen_string_literal: true

module Bookings
  class RescheduleService < BaseService
    def call(booking:, params:)
      unless booking.confirmed?
        return failure("Only confirmed bookings can be rescheduled")
      end

      unless booking.update(params)
        return failure(booking.errors.full_messages)
      end

      success(booking)
    rescue StandardError => e
      failure("Failed to reschedule booking: #{e.message}")
    end
  end
end
