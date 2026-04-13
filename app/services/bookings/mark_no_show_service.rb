# frozen_string_literal: true

module Bookings
  class MarkNoShowService < BaseService
    def call(booking:)
      unless booking.confirmed?
        return failure("Only confirmed bookings can be marked as no-show")
      end

      booking.mark_no_show!
      success(booking)
    rescue StandardError => e
      failure("Failed to mark booking as no-show: #{e.message}")
    end
  end
end
