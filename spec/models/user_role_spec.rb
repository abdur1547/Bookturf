# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserRole, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:role) }
    it { should belong_to(:assigned_by).class_name('User').optional }
  end

  describe 'validations' do
    subject { build(:user_role) }

    it 'validates uniqueness of user_id scoped to role_id' do
      user = create(:user)
      role = create(:role, :customer)
      create(:user_role, user: user, role: role)

      duplicate = build(:user_role, user: user, role: role)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to be_present
    end

    it 'allows same user with different roles' do
      user = create(:user)
      role1 = create(:role, :customer)
      role2 = create(:role, :staff)

      create(:user_role, user: user, role: role1)
      ur2 = build(:user_role, user: user, role: role2)

      expect(ur2).to be_valid
    end
  end

  describe 'callbacks' do
    it 'sets assigned_at on create' do
      user_role = build(:user_role, assigned_at: nil)
      expect(user_role.assigned_at).to be_nil
      user_role.save!
      expect(user_role.assigned_at).to be_present
    end

    it 'does not override existing assigned_at' do
      time = 1.day.ago
      user_role = create(:user_role, assigned_at: time)
      expect(user_role.assigned_at).to be_within(1.second).of(time)
    end
  end

  describe 'scopes' do
    describe '.recent' do
      let!(:old_assignment) { create(:user_role, assigned_at: 2.days.ago) }
      let!(:new_assignment) { create(:user_role, assigned_at: 1.hour.ago) }

      it 'returns assignments in descending order of assigned_at' do
        expect(UserRole.recent.first).to eq(new_assignment)
        expect(UserRole.recent.last).to eq(old_assignment)
      end
    end
  end
end
