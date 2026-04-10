# frozen_string_literal: true

FactoryBot.define do
  factory :user_role do
    user
    role
    assigned_by { nil }
    assigned_at { Time.current }
  end
end
