# frozen_string_literal: true

module Courts
  class DeleteService < BaseService
    def call(court:)
      if court.destroy
        success(court)
      else
        failure(court.errors.full_messages)
      end
    rescue StandardError => e
      failure("Failed to delete court: #{e.message}")
    end
  end
end
