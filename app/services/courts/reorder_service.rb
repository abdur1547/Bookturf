# frozen_string_literal: true

module Courts
  class ReorderService < BaseService
    def call(court:, display_order:)
      unless court.update(display_order: display_order)
        return failure(court.errors.full_messages)
      end

      success(court)
    rescue StandardError => e
      failure("Failed to reorder court: #{e.message}")
    end
  end
end
