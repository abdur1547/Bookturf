# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'associations' do
    it { should have_many(:role_permissions).dependent(:destroy) }
    it { should have_many(:permissions).through(:role_permissions) }
    it { should have_many(:user_roles).dependent(:destroy) }
    it { should have_many(:users).through(:user_roles) }
  end

  describe 'validations' do
    subject { build(:role) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_uniqueness_of(:slug) }

    it 'validates slug format' do
      role = build(:role, slug: 'Invalid Slug!')
      expect(role).not_to be_valid
      expect(role.errors[:slug]).to include('only lowercase letters, numbers, hyphens, and underscores')
    end

    it 'allows valid slug formats' do
      valid_slugs = %w[owner admin user_admin staff-member staff_123]
      valid_slugs.each do |slug|
        role = build(:role, slug: slug)
        expect(role).to be_valid
      end
    end
  end

  describe 'callbacks' do
    it 'generates slug from name if blank' do
      role = create(:role, name: 'Custom Manager', slug: nil)
      expect(role.slug).to eq('custom_manager')
    end

    it 'does not override existing slug' do
      role = create(:role, name: 'Test Role', slug: 'custom_slug')
      expect(role.slug).to eq('custom_slug')
    end

    context 'on destroy' do
      it 'prevents deletion of system roles' do
        role = create(:role, :owner)
        expect { role.destroy }.not_to change(Role, :count)
        expect(role.errors[:base]).to include('System roles cannot be deleted')
      end

      it 'allows deletion of custom roles' do
        role = create(:role, :custom_role)
        expect { role.destroy }.to change(Role, :count).by(-1)
      end
    end
  end

  describe 'scopes' do
    let!(:system_role) { create(:role, :owner) }
    let!(:custom_role) { create(:role, :custom_role) }

    describe '.system_roles' do
      it 'returns only system roles' do
        expect(Role.system_roles).to include(system_role)
        expect(Role.system_roles).not_to include(custom_role)
      end
    end

    describe '.custom_roles' do
      it 'returns only custom roles' do
        expect(Role.custom_roles).to include(custom_role)
        expect(Role.custom_roles).not_to include(system_role)
      end
    end

    describe '.alphabetical' do
      let!(:role_z) { create(:role, name: 'Zebra Role') }
      let!(:role_a) { create(:role, name: 'Alpha Role') }

      it 'returns roles in alphabetical order' do
        expect(Role.alphabetical.first).to eq(role_a)
        expect(Role.alphabetical.last).to eq(role_z)
      end
    end
  end

  describe '.find_by_slug!' do
    let!(:role) { create(:role, slug: 'test_role') }

    it 'finds role by slug' do
      expect(Role.find_by_slug!('test_role')).to eq(role)
    end

    it 'raises error if not found' do
      expect { Role.find_by_slug!('nonexistent') }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#system_role?' do
    it 'returns true for system roles' do
      role = create(:role, :owner)
      expect(role.system_role?).to be true
    end

    it 'returns false for custom roles' do
      role = create(:role, :custom_role)
      expect(role.system_role?).to be false
    end
  end

  describe '#custom_role?' do
    it 'returns true for custom roles' do
      role = create(:role, :custom_role)
      expect(role.custom_role?).to be true
    end

    it 'returns false for system roles' do
      role = create(:role, :owner)
      expect(role.custom_role?).to be false
    end
  end

  describe '#add_permission' do
    let(:role) { create(:role) }
    let(:permission) { create(:permission, :create_bookings) }

    it 'adds permission to role' do
      expect { role.add_permission(permission) }
        .to change { role.permissions.count }.by(1)
    end

    it 'does not duplicate permission' do
      role.add_permission(permission)
      expect { role.add_permission(permission) }
        .not_to change { role.permissions.count }
    end
  end

  describe '#remove_permission' do
    let(:role) { create(:role) }
    let(:permission) { create(:permission, :create_bookings) }

    before { role.add_permission(permission) }

    it 'removes permission from role' do
      expect { role.remove_permission(permission) }
        .to change { role.permissions.count }.by(-1)
    end
  end

  describe '#has_permission?' do
    let(:role) { create(:role) }
    let(:permission) { create(:permission, :create_bookings) }

    context 'when role has permission' do
      before { role.add_permission(permission) }

      it 'returns true' do
        expect(role.has_permission?(permission.name)).to be true
      end
    end

    context 'when role does not have permission' do
      it 'returns false' do
        expect(role.has_permission?(permission.name)).to be false
      end
    end
  end

  describe '#to_param' do
    let(:role) { create(:role, slug: 'custom_slug') }

    it 'returns the slug' do
      expect(role.to_param).to eq('custom_slug')
    end
  end
end
