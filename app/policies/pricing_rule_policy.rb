# frozen_string_literal: true

class PricingRulePolicy < ApplicationPolicy
  def index?
    user.present? && (user.owner? || user.admin? || user.receptionist?)
  end

  def show?
    index?
  end

  def create?
    user.present? && (user.owner? || user.admin?)
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user.present? && (user.owner? || user.admin? || user.receptionist?)

      scope.where(venue_id: venue_ids)
    end

    private

    def venue_ids
      (user.venues.pluck(:id) + user.owned_venues.pluck(:id)).uniq
    end
  end
end
