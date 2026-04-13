# frozen_string_literal: true

module Api::V0
  class CourtTypeBlueprint < BaseBlueprint
    identifier :id

    fields :name,
           :slug,
           :description

    view :minimal do
      fields :id,
             :name,
             :slug
    end
  end
end
