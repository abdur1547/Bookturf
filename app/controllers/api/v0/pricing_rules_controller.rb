# frozen_string_literal: true

module Api::V0
  class PricingRulesController < ApiController
    # GET /api/v0/pricing_rules
    def index
      result = Api::V0::PricingRules::ListPricingRulesOperation.call(params.to_unsafe_h, current_user)

      handle_operation_response(result)
    end

    # GET /api/v0/pricing_rules/:id
    def show
      result = Api::V0::PricingRules::GetPricingRuleOperation.call(params.to_unsafe_h, current_user)

      handle_operation_response(result)
    end

    # POST /api/v0/pricing_rules
    def create
      result = Api::V0::PricingRules::CreatePricingRuleOperation.call(params.to_unsafe_h, current_user)

      handle_operation_response(result, :created)
    end

    # PATCH/PUT /api/v0/pricing_rules/:id
    def update
      result = Api::V0::PricingRules::UpdatePricingRuleOperation.call(params.to_unsafe_h, current_user)

      handle_operation_response(result)
    end

    # DELETE /api/v0/pricing_rules/:id
    def destroy
      result = Api::V0::PricingRules::DeletePricingRuleOperation.call(params.to_unsafe_h, current_user)

      handle_operation_response(result)
    end
  end
end
