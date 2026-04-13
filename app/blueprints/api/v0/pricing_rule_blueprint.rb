# frozen_string_literal: true

module Api::V0
  class PricingRuleBlueprint < BaseBlueprint
    identifier :id

    fields :venue_id,
           :court_type_id,
           :name,
           :price_per_hour,
           :day_of_week,
           :start_time,
           :end_time,
           :start_date,
           :end_date,
           :priority,
           :is_active,
           :day_name,
           :time_range,
           :created_at,
           :updated_at

    view :list do
      association :court_type, blueprint: Api::V0::CourtTypeBlueprint, view: :minimal
    end

    view :detailed do
      association :court_type, blueprint: Api::V0::CourtTypeBlueprint, view: :minimal
    end
  end
end
