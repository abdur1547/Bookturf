# frozen_string_literal: true

module Bookings
  class DeleteService < BaseService
    def call(booking:)
      if booking.destroy
        success(booking)
      else
        failure(booking.errors.full_messages)
      end
    rescue StandardError => e
      failure("Failed to delete booking: #{e.message}")
    end
  end
end
