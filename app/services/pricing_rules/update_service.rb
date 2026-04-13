# frozen_string_literal: true

module PricingRules
  class UpdateService < BaseService
    def call(pricing_rule:, params:)
      unless pricing_rule.update(params)
        return failure(pricing_rule.errors.full_messages)
      end

      success(pricing_rule)
    rescue StandardError => e
      failure("Failed to update pricing rule: #{e.message}")
    end
  end
end
