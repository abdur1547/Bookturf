# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:record) { double('record') }

  subject { described_class.new(user, record) }

  describe 'default permissions' do
    it 'denies index' do
      expect(subject.index?).to be false
    end

    it 'denies show' do
      expect(subject.show?).to be false
    end

    it 'denies create' do
      expect(subject.create?).to be false
    end

    it 'denies new' do
      expect(subject.new?).to be false
    end

    it 'denies update' do
      expect(subject.update?).to be false
    end

    it 'denies edit' do
      expect(subject.edit?).to be false
    end

    it 'denies destroy' do
      expect(subject.destroy?).to be false
    end
  end

  describe 'Scope' do
    subject { described_class::Scope.new(user, double) }

    it 'raises NoMethodError when resolve is not implemented' do
      expect { subject.resolve }.to raise_error(NoMethodError)
    end
  end
end
