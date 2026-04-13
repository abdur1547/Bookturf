# frozen_string_literal: true

module Bookings
  class UpdateService < BaseService
    def call(booking:, params:)
      unless booking.update(params)
        return failure(booking.errors.full_messages)
      end

      success(booking)
    rescue StandardError => e
      failure("Failed to update booking: #{e.message}")
    end
  end
end
