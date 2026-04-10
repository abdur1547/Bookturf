# frozen_string_literal: true

module Api::V0
  class UserBlueprint < BaseBlueprint
    identifier :id

    field :email
    field :name do |user|
      user.full_name
    end

    view :profile do
      field :name do |user|
        user.full_name
      end
      fields :email, :avatar_url, :created_at
      field :member_since do |user|
        "Member since #{user.created_at&.strftime('%B %Y')}"
      end
    end

    view :minimal do
      fields :id
      field :name do |user|
        user.full_name
      end
    end
  end
end
