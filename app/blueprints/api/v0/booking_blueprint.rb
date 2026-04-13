# frozen_string_literal: true

module Api::V0
  class BookingBlueprint < BaseBlueprint
    identifier :id

    fields :booking_number,
           :status,
           :payment_method,
           :payment_status,
           :total_amount,
           :paid_amount,
           :notes,
           :cancellation_reason,
           :cancelled_at,
           :checked_in_at,
           :start_time,
           :end_time,
           :duration_minutes,
           :created_at,
           :updated_at

    view :list do
      fields :status,
             :total_amount,
             :paid_amount,
             :payment_method,
             :payment_status,
             :start_time,
             :end_time

      association :user, blueprint: Api::V0::UserBlueprint, view: :minimal
      association :court, blueprint: Api::V0::CourtBlueprint, view: :minimal
    end

    view :detailed do
      fields :status,
             :total_amount,
             :paid_amount,
             :payment_method,
             :payment_status,
             :notes,
             :cancellation_reason,
             :cancelled_at,
             :checked_in_at,
             :start_time,
             :end_time,
             :duration_minutes

      association :user, blueprint: Api::V0::UserBlueprint, view: :minimal
      association :court, blueprint: Api::V0::CourtBlueprint, view: :minimal
      association :venue, blueprint: Api::V0::VenueBlueprint, view: :minimal
    end

    view :minimal do
      fields :booking_number,
             :status,
             :start_time,
             :end_time
    end
  end
end
