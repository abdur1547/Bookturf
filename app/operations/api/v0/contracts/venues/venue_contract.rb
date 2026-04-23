module Api::V0::Contracts::Venues
  class VenueContract < Dry::Validation::Contract
    params do
      required(:name).filled(:string)
      optional(:description).maybe(:string)
      required(:address).filled(:string)
      required(:city).filled(:string)
      required(:state).filled(:string)
      required(:country).filled(:string)
      optional(:postal_code).maybe(:string)
      optional(:latitude).maybe(:decimal)
      optional(:longitude).maybe(:decimal)
      optional(:phone_number).maybe(:string)
      optional(:email).maybe(:string)
      optional(:is_active).maybe(:bool)

      optional(:venue_setting).maybe(:hash) do
        optional(:minimum_slot_duration).maybe(:integer)
        optional(:maximum_slot_duration).maybe(:integer)
        optional(:slot_interval).maybe(:integer)
        optional(:advance_booking_days).maybe(:integer)
        optional(:requires_approval).maybe(:bool)
        optional(:cancellation_hours).maybe(:integer)
        optional(:timezone).maybe(:string)
        optional(:currency).maybe(:string)
      end

      optional(:venue_operating_hours).maybe(:array) do
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

    # rule(:venue_operating_hours) do
    #   next if values[:venue_operating_hours].blank?

    #   hours = values[:venue_operating_hours]

    #   # Validate exactly 7 entries (one for each day of week)
    #   if hours.size != 7
    #     key.failure("must have exactly 7 entries (one for each day of the week)")
    #     next
    #   end

    #   # Collect all day_of_week values
    #   days = hours.map { |h| h[:day_of_week] }.compact

    #   # Validate all days are unique and in range 0-6
    #   if days.size != 7
    #     key.failure("all days of week (0-6) must be present")
    #     next
    #   end

    #   unless days.sort == (0..6).to_a
    #     key.failure("day_of_week must contain all values from 0 to 6")
    #     next
    #   end

    #   # Validate each operating hour entry
    #   hours.each_with_index do |hour, index|
    #     day_of_week = hour[:day_of_week]
    #     opens_at = hour[:opens_at]
    #     closes_at = hour[:closes_at]
    #     is_closed = hour[:is_closed]

    #     # If not closed, both times are required
    #     if is_closed != true
    #       if opens_at.blank? || closes_at.blank?
    #         key.failure("opens_at and closes_at are required when is_closed is not true (day #{day_of_week})")
    #         next
    #       end

    #       # Validate time format (HH:MM)
    #       unless valid_time_format?(opens_at)
    #         key.failure("opens_at has invalid format for day #{day_of_week}. Format must be HH:MM")
    #         next
    #       end

    #       unless valid_time_format?(closes_at)
    #         key.failure("closes_at has invalid format for day #{day_of_week}. Format must be HH:MM")
    #         next
    #       end

    #       # Validate closes_at is after opens_at
    #       unless time_is_after?(closes_at, opens_at)
    #         key.failure("closes_at must be after opens_at for day #{day_of_week}")
    #         next
    #       end
    #     end
    #   end
    # end

    # private

    # def valid_time_format?(time_str)
    #   return false if time_str.blank?
    #   time_str.match?(/^\d{2}:\d{2}$/)
    # end

    # def time_is_after?(time_a, time_b)
    #   return false if time_a.blank? || time_b.blank?

    #   hours_a, mins_a = time_a.split(":").map(&:to_i)
    #   hours_b, mins_b = time_b.split(":").map(&:to_i)

    #   total_mins_a = hours_a * 60 + mins_a
    #   total_mins_b = hours_b * 60 + mins_b

    #   total_mins_a > total_mins_b
    # end
  end
end
