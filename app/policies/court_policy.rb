# frozen_string_literal: true

class CourtPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.present?
  end

  def update?
    return false unless user.present?

    owner? || global_admin?
  end

  def destroy?
    return false unless user.present?

    owner? || global_admin?
  end

  private

  def owner?
    return false unless record.is_a?(Court)

    record.venue.owner_id == user.id
  end

  def global_admin?
    user.admin?
  end
end
