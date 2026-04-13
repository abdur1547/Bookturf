# frozen_string_literal: true

module PricingRules
  class DeleteService < BaseService
    def call(pricing_rule:)
      if pricing_rule.destroy
        success(pricing_rule)
      else
        failure(pricing_rule.errors.full_messages)
      end
    rescue StandardError => e
      failure("Failed to delete pricing rule: #{e.message}")
    end
  end
end
