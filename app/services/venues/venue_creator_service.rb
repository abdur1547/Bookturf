# frozen_string_literal: true

module Venues
  class VenueCreatorService < BaseService
    def call(params:, owner:)
      @params = params
      @owner = owner

       validation_result = Venues::OperatingHoursValidatorService.call(
          operating_hours: params[:venue_operating_hours]
        )
       return validation_result unless validation_result.success?

      ActiveRecord::Base.transaction do
        venue = Venue.create!(venue_params)
        venue.create_venue_setting!(venue_settings_params)
        venue.venue_operating_hours.create!(venue_hours_params(venue))

        return success(venue.reload)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end

    private
    attr_reader :params, :owner

    def validate_operating_hours
      if params[:venue_operating_hours].present?
        validation_result = Venues::OperatingHoursValidatorService.call(
          operating_hours: params[:venue_operating_hours]
        )
        return failure(validation_result) unless validation_result.success?
        success(validation_result)
      end
    end

    def venue_params
      {
        name: params[:name],
        description: params[:description],
        address: params[:address],
        city: params[:city],
        # area: params[:area],
        state: params[:state],
        country: params[:country],
        postal_code: params[:postal_code],
        latitude: params[:latitude],
        longitude: params[:longitude],
        phone_number: params[:phone_number],
        email: params[:email],
        is_active: params[:is_active] || true,
        owner_id: owner.id
      }
    end

    def venue_settings_params
      {
        minimum_slot_duration: params[:venue_setting][:minimum_slot_duration] || 60,
        maximum_slot_duration: params[:venue_setting][:maximum_slot_duration] || 60,
        slot_interval: params[:venue_setting][:slot_interval] || 60,
        advance_booking_days: params[:venue_setting][:advance_booking_days] || 7,
        requires_approval: params[:venue_setting][:requires_approval] || false,
        cancellation_hours: params[:venue_setting][:cancellation_hours] || 0,
        timezone: params[:venue_setting][:timezone] || "Asia/Karachi",
        currency: params[:venue_setting][:currency] || "PKR"
    }.compact
    end

    def venue_hours_params(venue)
      return params[:venue_operating_hours] if params[:venue_operating_hours].present?

      (0..6).each do |day|
        {
          day_of_week: day,
          opens_at: "09:00",
          closes_at: "23:00",
          is_closed: false
        }
      end
    end
  end
end
