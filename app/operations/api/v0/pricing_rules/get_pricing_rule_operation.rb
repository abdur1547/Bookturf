# frozen_string_literal: true

module Api::V0::PricingRules
  class GetPricingRuleOperation < BaseOperation
    contract do
      params do
        required(:id).filled
      end
    end

    def call(params, current_user)
      @params = params
      @current_user = current_user

      @pricing_rule = find_pricing_rule(params[:id])
      return Failure(:not_found) unless @pricing_rule
      return Failure(:forbidden) unless authorize?

      json_data = serialize
      Success(pricing_rule: @pricing_rule, json: json_data)
    end

    private

    attr_reader :params, :current_user, :pricing_rule

    def authorize?
      PricingRulePolicy.new(current_user, pricing_rule).show?
    end

    def find_pricing_rule(id)
      PricingRule.includes(:court_type)
                 .find_by(id: id, venue_id: accessible_venue_ids)
    end

    def accessible_venue_ids
      (current_user.venues.pluck(:id) + current_user.owned_venues.pluck(:id)).uniq
    end

    def serialize
      Api::V0::PricingRuleBlueprint.render_as_hash(pricing_rule, view: :detailed)
    end
  end
end
