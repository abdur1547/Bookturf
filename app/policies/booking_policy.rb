# frozen_string_literal: true

class BookingPolicy < ApplicationPolicy
  def index?
    user.present? && (user.can?("read", "bookings") || user.can?("manage", "bookings"))
  end

  def show?
    return false unless user.present?

    user.can?("read", "bookings") || user.can?("manage", "bookings") || record.user_id == user.id
  end

  def create?
    user.present? && (user.can?("create", "bookings") || user.can?("manage", "bookings"))
  end

  def update?
    return false unless user.present?

    user.can?("update", "bookings") || user.can?("manage", "bookings") || record.user_id == user.id
  end

  def destroy?
    return false unless user.present?

    user.can?("manage", "bookings") || record.user_id == user.id
  end

  def cancel?
    return false unless user.present?

    user.can?("manage", "bookings") || record.user_id == user.id
  end

  def check_in?
    user.present? && user.can?("manage", "bookings")
  end

  def mark_no_show?
    user.present? && user.can?("manage", "bookings")
  end

  def complete?
    user.present? && user.can?("manage", "bookings")
  end

  def reschedule?
    return false unless user.present?

    user.can?("update", "bookings") || user.can?("manage", "bookings") || record.user_id == user.id
  end
end
