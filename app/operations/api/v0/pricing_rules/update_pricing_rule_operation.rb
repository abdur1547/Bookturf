# frozen_string_literal: true

module Api::V0::PricingRules
  class UpdatePricingRuleOperation < BaseOperation
    contract do
      params do
        required(:id).filled
        required(:pricing_rule).hash do
          optional(:court_type_id).maybe(:integer)
          optional(:name).maybe(:string)
          optional(:price_per_hour).maybe(:float)
          optional(:day_of_week).maybe(:integer)
          optional(:start_time).maybe(:string)
          optional(:end_time).maybe(:string)
          optional(:start_date).maybe(:string)
          optional(:end_date).maybe(:string)
          optional(:priority).maybe(:integer)
          optional(:is_active).maybe(:bool)
        end
      end
    end

    def call(params, current_user)
      @params = params
      @current_user = current_user
      pricing_rule_params = params[:pricing_rule]

      @pricing_rule = find_pricing_rule(params[:id])
      return Failure(:not_found) unless @pricing_rule
      return Failure(:forbidden) unless authorize?

      result = PricingRules::UpdateService.call(pricing_rule: @pricing_rule, params: pricing_rule_params)
      return Failure(result.error) unless result.success?

      @pricing_rule = result.data
      json_data = serialize
      Success(pricing_rule: @pricing_rule, json: json_data)
    end

    private

    attr_reader :params, :current_user, :pricing_rule

    def authorize?
      PricingRulePolicy.new(current_user, pricing_rule).update?
    end

    def find_pricing_rule(id)
      PricingRule.find_by(id: id, venue_id: accessible_venue_ids)
    end

    def accessible_venue_ids
      (current_user.venues.pluck(:id) + current_user.owned_venues.pluck(:id)).uniq
    end

    def serialize
      Api::V0::PricingRuleBlueprint.render_as_hash(pricing_rule, view: :detailed)
    end
  end
end
