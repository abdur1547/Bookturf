# frozen_string_literal: true

module Courts
  class CreateService < BaseService
    def call(params:)
      court = Court.new(params)

      unless court.save
        return failure(court.errors.full_messages)
      end

      success(court)
    rescue StandardError => e
      failure("Failed to create court: #{e.message}")
    end
  end
end
