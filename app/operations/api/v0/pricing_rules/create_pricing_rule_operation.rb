# frozen_string_literal: true

module Api::V0::PricingRules
  class CreatePricingRuleOperation < BaseOperation
    contract do
      params do
        required(:pricing_rule).hash do
          required(:court_type_id).filled(:integer)
          required(:name).filled(:string)
          required(:price_per_hour).filled
          optional(:day_of_week).maybe(:integer)
          optional(:start_time).maybe(:string)
          optional(:end_time).maybe(:string)
          optional(:start_date).maybe(:string)
          optional(:end_date).maybe(:string)
          required(:priority).filled(:integer)
          optional(:is_active).maybe(:bool)
        end
      end
    end

    def call(params, current_user)
      @params = params
      @current_user = current_user
      pricing_rule_params = params[:pricing_rule]

      return Failure(:unauthorized) unless authorize?
      @venue = current_user.venues.first || current_user.owned_venues.first
      return Failure(error: "Venue not found") unless @venue

      create_params = pricing_rule_params.merge(venue_id: @venue.id)
      result = PricingRules::CreateService.call(params: create_params)
      return Failure(error: result.error) unless result.success?

      @pricing_rule = result.data
      json_data = serialize
      Success(pricing_rule: @pricing_rule, json: json_data)
    end

    private

    attr_reader :params, :current_user, :pricing_rule, :venue

    def authorize?
      PricingRulePolicy.new(current_user, PricingRule).create?
    end

    def serialize
      Api::V0::PricingRuleBlueprint.render_as_hash(pricing_rule, view: :detailed)
    end
  end
end
