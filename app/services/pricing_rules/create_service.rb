# frozen_string_literal: true

module PricingRules
  class CreateService < BaseService
    def call(params:)
      pricing_rule = PricingRule.new(params)

      unless pricing_rule.save
        return failure(pricing_rule.errors.full_messages)
      end

      success(pricing_rule)
    rescue StandardError => e
      failure("Failed to create pricing rule: #{e.message}")
    end
  end
end
