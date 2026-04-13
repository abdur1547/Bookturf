# frozen_string_literal: true

module Api::V0
  class CourtBlueprint < BaseBlueprint
    identifier :id

    fields :name,
           :description,
           :court_type_id,
           :venue_id,
           :is_active,
           :display_order,
           :created_at

    view :list do
      fields :updated_at

      association :court_type, blueprint: Api::V0::CourtTypeBlueprint, view: :minimal
      association :venue, blueprint: Api::V0::VenueBlueprint, view: :minimal do |court|
        court.venue
      end
    end

    view :detailed do
      fields :updated_at

      association :court_type, blueprint: Api::V0::CourtTypeBlueprint, view: :minimal
      association :venue, blueprint: Api::V0::VenueBlueprint, view: :minimal do |court|
        court.venue
      end
    end

    view :minimal do
      fields :id,
             :name,
             :is_active,
             :court_type_id,
             :venue_id
    end
  end
end
