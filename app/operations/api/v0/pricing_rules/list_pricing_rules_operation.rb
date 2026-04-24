# frozen_string_literal: true

module Api::V0::PricingRules
  class ListPricingRulesOperation < BaseOperation
    contract do
      params do
        optional(:court_type_id).maybe(:integer)
        optional(:is_active).maybe(:bool)
        optional(:day_of_week).maybe(:integer)
      end
    end

    def call(params, current_user)
      @params = params
      @current_user = current_user

      return Failure(:forbidden) unless authorize?

      @pricing_rules = pricing_rules_scope
      @pricing_rules = @pricing_rules.where(court_type_id: params[:court_type_id]) if params[:court_type_id].present?

      if params.key?(:is_active)
        if params[:is_active] == true || params[:is_active] == "true"
          @pricing_rules = @pricing_rules.active
        elsif params[:is_active] == false || params[:is_active] == "false"
          @pricing_rules = @pricing_rules.where(is_active: false)
        end
      end

      if params[:day_of_week].present?
        @pricing_rules = @pricing_rules.where(
          "day_of_week = ? OR day_of_week IS NULL",
          params[:day_of_week]
        )
      end

      @pricing_rules = @pricing_rules.order(priority: :desc, name: :asc)
      json_data = serialize

      Success(pricing_rules: @pricing_rules, json: json_data)
    end

    private

    attr_reader :params, :current_user, :pricing_rules

    def authorize?
      PricingRulePolicy.new(current_user, PricingRule).index?
    end

    def pricing_rules_scope
      PricingRule.includes(:court_type).where(venue_id: accessible_venue_ids)
    end

    def accessible_venue_ids
      (current_user.venues.pluck(:id) + current_user.owned_venues.pluck(:id)).uniq
    end

    def serialize
      Api::V0::PricingRuleBlueprint.render_as_hash(pricing_rules, view: :list)
    end
  end
end
