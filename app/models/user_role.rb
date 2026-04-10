# frozen_string_literal: true

class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role
  belongs_to :assigned_by, class_name: "User", optional: true

  validates :user_id, uniqueness: { scope: :role_id }

  before_validation :set_assigned_at, if: :new_record?

  scope :recent, -> { order(assigned_at: :desc) }

  private

  def set_assigned_at
    self.assigned_at ||= Time.current
  end
end
