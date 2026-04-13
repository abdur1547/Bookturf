# frozen_string_literal: true

FactoryBot.define do
  factory :court_type do
    sequence(:name) { |n| "Court Type #{n}" }
    sequence(:slug) { |n| "court-type-#{n}" }
    description { "Sports court type" }
  end
end
