# frozen_string_literal: true

FactoryBot.define do
  factory :permission do
    sequence(:resource) { |n| Permission::RESOURCES.sample }
    sequence(:action) { |n| Permission::ACTIONS.sample }
    # name will be auto-generated from resource and action
    description { "Can #{action} #{resource}" }

    trait :create_bookings do
      resource { 'bookings' }
      action { 'create' }
    end

    trait :read_bookings do
      resource { 'bookings' }
      action { 'read' }
    end

    trait :manage_bookings do
      resource { 'bookings' }
      action { 'manage' }
    end

    trait :read_courts do
      resource { 'courts' }
      action { 'read' }
    end
  end
end
