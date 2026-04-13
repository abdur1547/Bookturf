# frozen_string_literal: true

module Courts
  class UpdateService < BaseService
    def call(court:, params:)
      unless court.update(params)
        return failure(court.errors.full_messages)
      end

      success(court)
    rescue StandardError => e
      failure("Failed to update court: #{e.message}")
    end
  end
end
