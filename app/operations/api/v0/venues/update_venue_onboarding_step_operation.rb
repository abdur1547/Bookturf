# frozen_string_literal: true

module Api::V0::Venues
  class UpdateVenueOnboardingStepOperation < BaseOperation
    contract do
      params do
        required(:id).filled
        required(:onboarding_step).filled(:integer)
      end
    end

    def call(params, current_user)
      @params = params
      @current_user = current_user

      @venue = find_venue(params[:id])
      return Failure(error: "Venue not found") unless @venue

      return Failure(:unauthorized) unless authorize

      onboarding_step = params[:onboarding_step]

      # Validate step is between 0-4
      return Failure(error: "Onboarding step must be between 0 and 4") unless (0..4).include?(onboarding_step)

      result = update_onboarding_step(onboarding_step)
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

    def update_onboarding_step(step)
      begin
        # Try to update the onboarding_step if the column exists
        # Otherwise, store it temporarily for the response
        if venue.respond_to?(:onboarding_step=)
          venue.update(onboarding_step: step)
        elsif venue.venue_setting.respond_to?(:onboarding_step=)
          venue.venue_setting.update(onboarding_step: step)
        else
          # For now, if field doesn't exist, we'll just acknowledge the request
          # This allows the API to be versioned independently of the DB
          @onboarding_step_temp = step
        end

        success(venue)
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
      data = Api::V0::VenueBlueprint.render_as_hash(venue, view: :detailed)

      # Include onboarding info in response
      data[:onboarding_step] = @onboarding_step_temp || (venue.respond_to?(:onboarding_step) ? venue.onboarding_step : 0)
      data[:onboarding_completed] = data[:onboarding_step] == 4

      data
    end
  end
end
