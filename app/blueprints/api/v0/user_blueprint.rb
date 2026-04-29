# frozen_string_literal: true

module Api::V0
  class UserBlueprint < BaseBlueprint
    identifier :id

    fields :full_name, :email, :avatar_url, :created_at, :updated_at, :phone_number

    field :user_type do |user|
      if user.owner?
        "owner"
      elsif user.staff?
        "staff"
      else
        "customer"
      end
    end

    # User preferences
    field :preferences do |user|
      {
        preferred_city: nil,
        preferred_town: nil,
        notification_reminders: true,
        notification_30min: true
      }
    end

    # Owner-specific data
    field :owner_data do |user|
      if user.owner?
        owner_venue = user.owned_venues.first
        {
          venue_id: owner_venue&.id
        }
      else
        nil
      end
    end

    # Staff-specific data
    field :staff_data do |user|
      if user.staff?
        venue_user = user.venue_users.first
        {
          venue_id: venue_user&.venue_id,
          joined_at: venue_user&.created_at
        }
      else
        nil
      end
    end

    view :minimal do
      fields :id, :full_name
    end
  end
end
