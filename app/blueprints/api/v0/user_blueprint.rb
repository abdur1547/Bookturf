# frozen_string_literal: true

module Api::V0
  class UserBlueprint < BaseBlueprint
    identifier :id

    fields :full_name, :email, :avatar_url, :created_at, :updated_at

    field :phone do |user|
      user.phone_number
    end

    field :user_type do |user|
      if user.owner?
        "owner"
      elsif user.staff?
        "staff"
      else
        "customer"
      end
    end

    # Placeholder for email verification timestamp
    field :email_verified_at do |user|
      # TODO: Add email_verified_at migration if needed
      nil
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

    view :profile do
      fields :full_name, :email, :avatar_url, :created_at
      field :member_since do |user|
        "Member since #{user.created_at&.strftime('%B %Y')}"
      end
    end

    view :minimal do
      fields :id, :full_name
    end

    view :detailed do
      fields :id, :full_name, :email, :avatar_url, :phone_number,
             :created_at, :updated_at

      field :user_type do |user|
        if user.owner?
          "owner"
        elsif user.staff?
          "staff"
        else
          "customer"
        end
      end
    end
  end
end
