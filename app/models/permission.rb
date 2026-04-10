# frozen_string_literal: true

class Permission < ApplicationRecord
  ACTIONS = %w[create read update delete manage].freeze

  RESOURCES = %w[
    bookings courts venues users roles reports settings
    pricing closures notifications
  ].freeze

  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  validates :resource, presence: true
  validates :action, presence: true
  validates :name, uniqueness: true, allow_blank: true
  validates :resource, inclusion: { in: RESOURCES }
  validates :action, inclusion: { in: ACTIONS }

  validate :name_matches_resource_and_action

  before_validation :generate_name, if: -> { name.blank? && resource.present? && action.present? }

  scope :for_resource, ->(resource) { where(resource: resource) }
  scope :for_action, ->(action) { where(action: action) }
  scope :alphabetical, -> { order(:name) }

  def self.find_by_name!(name)
    find_by!(name: name)
  end

  def to_s
    name
  end

  private

  def generate_name
    self.name = "#{action}:#{resource}"
  end

  def name_matches_resource_and_action
    return if name.blank? || resource.blank? || action.blank?

    expected_name = "#{action}:#{resource}"
    unless name == expected_name
      errors.add(:name, "must be '#{expected_name}' based on resource and action")
    end
  end
end
