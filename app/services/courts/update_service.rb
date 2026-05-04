# frozen_string_literal: true

module Courts
  class UpdateService < BaseService
    def call(court:, params:, pricing_rules: nil)
      ApplicationRecord.transaction do
        return failure(court.errors.full_messages) unless court.update!(params)

        replace_pricing_rules(court, pricing_rules) if pricing_rules

        success(court)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    rescue StandardError => e
      failure("Failed to update court: #{e.message}")
    end

    private

    def replace_pricing_rules(court, pricing_rules_params)
      court.pricing_rules.destroy_all
      pricing_rules_params.each do |rule_params|
        PricingRule.create!(
          rule_params.merge(
            court_id: court.id,
            venue_id: court.venue_id,
            priority: rule_params[:priority] || 0
          )
        )
      end
    end
  end
end
