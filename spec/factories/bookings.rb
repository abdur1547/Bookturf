# frozen_string_literal: true

FactoryBot.define do
  factory :booking do
    association :user
    association :court
    association :venue

    start_time { 1.day.from_now.change(hour: 10, min: 0) }
    end_time { start_time + 1.hour }
    status { 'confirmed' }
    payment_status { 'pending' }
    payment_method { 'cash' }
    notes { 'Booked for a private match' }

    after(:build) do |booking|
      booking.venue ||= booking.court&.venue
      booking.duration_minutes = ((booking.end_time - booking.start_time) / 60).to_i if booking.start_time && booking.end_time
    end
  end
end
