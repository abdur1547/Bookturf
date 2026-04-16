# frozen_string_literal: true

module Api::V0::Venues
  class UpdateVenueOperatingHoursOperation < BaseOperation
    contract do
      params do
        required(:id).filled
        required(:operating_hours).array do
          each do
            hash do
              required(:day_of_week).filled(:integer)
              optional(:opens_at).maybe(:string)
              optional(:closes_at).maybe(:string)
              optional(:is_closed).maybe(:bool)
            end
          end
        end
      end
    end

    def call(params, current_user)
      @params = params
      @current_user = current_user

      @venue = find_venue(params[:id])
      return Failure(error: "Venue not found") unless @venue

      return Failure(:unauthorized) unless authorize

      result = update_operating_hours(params[:operating_hours])
      return Failure(error: result.error) unless result.success?

      json_data = serialize

      Success(venue: @venue, json: json_data)
    end

    private

    attr_reader :params, :current_user, :venue

    def find_venue(id)
      # Support both ID and slug
      if id.to_s =~ /\A\d+\z/
        Venue.find_by(id: id)
      else
        Venue.find_by(slug: id)
      end
    end

    def authorize
      VenuePolicy.new(current_user, venue).update?
    end

    def update_operating_hours(operating_hours_params)
      begin
        ActiveRecord::Base.transaction do
          operating_hours_params.each do |hours_data|
            day_of_week = hours_data[:day_of_week]
            operating_hour = venue.venue_operating_hours.find_by(day_of_week: day_of_week)

            return failure("Operating hours for day #{day_of_week} not found") unless operating_hour

            # Update attributes
            operating_hour.assign_attributes(
              opens_at: hours_data[:opens_at],
              closes_at: hours_data[:closes_at],
              is_closed: hours_data[:is_closed]
            )

            return failure(operating_hour.errors.full_messages.join(", ")) unless operating_hour.save
          end

          success(venue)
        end
      rescue StandardError => e
        failure(e.message)
      end
    end

    def failure(error)
      OpenStruct.new(success?: false, error: error)
    end

    def success(data)
      OpenStruct.new(success?: true, data: data)
    end

    def serialize
      Api::V0::VenueBlueprint.render_as_hash(venue, view: :detailed)
    end
  end
end
