# frozen_string_literal: true

module Venues
  class VenueUpdaterService < BaseService
    def call(venue:, params:)
      @venue = venue
      @params = params

      if params.key?(:is_active) && venue.is_active != params[:is_active]
        validation_result = Venues::VenueActivationValidatorService.call(
          venue: venue,
          is_active: params[:is_active]
        )
        return validation_result unless validation_result.success?
      end

      if params[:venue_operating_hours].present?
        validation_result = Venues::OperatingHoursValidatorService.call(
          operating_hours: params[:venue_operating_hours],
          is_update: true
        )
        return validation_result unless validation_result.success?
      end

      ActiveRecord::Base.transaction do
        venue.update!(venue_params) if venue_params.present?
        update_operating_hours if params[:venue_operating_hours].present?
      end

      success(venue.reload)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end

    private

    attr_reader :venue, :params

    def venue_params
      allowed_keys = %i[name description address city state country postal_code
                        latitude longitude phone_number email timezone currency is_active]
      params.compact&.slice(*allowed_keys)
    end

    def update_operating_hours
      params[:venue_operating_hours].each do |hours|
        existing = venue.venue_operating_hours.find_by(day_of_week: hours[:day_of_week])
        existing.update!(hours) if existing
      end
    end
  end
end
