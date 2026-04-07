# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Permission, type: :model do
  describe 'associations' do
    it { should have_many(:role_permissions).dependent(:destroy) }
    it { should have_many(:roles).through(:role_permissions) }
  end

  describe 'validations' do
    subject { create(:permission, resource: 'bookings', action: 'create') }

    it { should validate_presence_of(:resource) }
    it { should validate_presence_of(:action) }

    it 'validates resource inclusion' do
      invalid_permission = build(:permission, resource: 'invalid_resource', action: 'create')
      expect(invalid_permission).not_to be_valid
      expect(invalid_permission.errors[:resource]).to be_present
    end

    it 'validates action inclusion' do
      invalid_permission = build(:permission, resource: 'bookings', action: 'invalid_action')
      expect(invalid_permission).not_to be_valid
      expect(invalid_permission.errors[:action]).to be_present
    end

    context 'name validation' do
      it 'is valid when name matches resource:action format' do
        permission = build(:permission, resource: 'bookings', action: 'create', name: 'create:bookings')
        expect(permission).to be_valid
      end

      it 'is invalid when name does not match resource:action format' do
        permission = build(:permission, resource: 'bookings', action: 'create', name: 'wrong:format')
        expect(permission).not_to be_valid
        expect(permission.errors[:name]).to include("must be 'create:bookings' based on resource and action")
      end
    end
  end

  describe 'callbacks' do
    it 'auto-generates name from resource and action' do
      permission = create(:permission, resource: 'bookings', action: 'create', name: nil)
      expect(permission.name).to eq('create:bookings')
    end

    it 'does not override existing name' do
      permission = create(:permission, resource: 'bookings', action: 'create', name: 'create:bookings')
      expect(permission.name).to eq('create:bookings')
    end
  end

  describe 'scopes' do
    let!(:booking_permission) { create(:permission, resource: 'bookings', action: 'create') }
    let!(:court_permission) { create(:permission, resource: 'courts', action: 'read') }
    let!(:another_booking_permission) { create(:permission, resource: 'bookings', action: 'read') }

    describe '.for_resource' do
      it 'returns permissions for specific resource' do
        bookings_permissions = Permission.for_resource('bookings')
        expect(bookings_permissions).to include(booking_permission, another_booking_permission)
        expect(bookings_permissions).not_to include(court_permission)
      end
    end

    describe '.for_action' do
      it 'returns permissions for specific action' do
        read_permissions = Permission.for_action('read')
        expect(read_permissions).to include(court_permission, another_booking_permission)
        expect(read_permissions).not_to include(booking_permission)
      end
    end

    describe '.alphabetical' do
      it 'returns permissions in alphabetical order by name' do
        permissions = Permission.alphabetical.pluck(:name)
        expect(permissions).to eq(permissions.sort)
      end
    end
  end

  describe '.find_by_name!' do
    let!(:permission) { create(:permission, resource: 'bookings', action: 'create') }

    it 'finds permission by name' do
      expect(Permission.find_by_name!('create:bookings')).to eq(permission)
    end

    it 'raises error if not found' do
      expect { Permission.find_by_name!('nonexistent:permission') }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#to_s' do
    let(:permission) { create(:permission, resource: 'bookings', action: 'create') }

    it 'returns the permission name' do
      expect(permission.to_s).to eq('create:bookings')
    end
  end
end
