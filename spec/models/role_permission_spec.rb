# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RolePermission, type: :model do
  describe 'associations' do
    it { should belong_to(:role) }
    it { should belong_to(:permission) }
  end

  describe 'validations' do
    subject { build(:role_permission) }

    it 'validates uniqueness of role_id scoped to permission_id' do
      role = create(:role)
      permission = create(:permission, resource: 'bookings', action: 'create')
      create(:role_permission, role: role, permission: permission)

      duplicate = build(:role_permission, role: role, permission: permission)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:role_id]).to be_present
    end

    it 'allows same role with different permissions' do
      role = create(:role)
      permission1 = create(:permission, resource: 'bookings', action: 'create')
      permission2 = create(:permission, resource: 'bookings', action: 'read')

      create(:role_permission, role: role, permission: permission1)
      rp2 = build(:role_permission, role: role, permission: permission2)

      expect(rp2).to be_valid
    end
  end
end
