# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "Role #{n}" }
    sequence(:slug) { |n| "role_#{n}" }
    description { "Test role description" }
    is_custom { true }

    trait :owner do
      name { 'Owner' }
      slug { 'owner' }
      description { 'Venue owner with full control' }
      is_custom { false }
    end

    trait :admin do
      name { 'Admin' }
      slug { 'admin' }
      description { 'Administrator with most permissions' }
      is_custom { false }
    end

    trait :receptionist do
      name { 'Receptionist' }
      slug { 'receptionist' }
      description { 'Front desk staff managing bookings' }
      is_custom { false }
    end

    trait :staff do
      name { 'Staff' }
      slug { 'staff' }
      description { 'General staff with basic access' }
      is_custom { false }
    end

    trait :customer do
      name { 'Customer' }
      slug { 'customer' }
      description { 'Regular user who books courts' }
      is_custom { false }
    end

    trait :system_role do
      is_custom { false }
    end

    trait :custom_role do
      is_custom { true }
    end
  end
end
