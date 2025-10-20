require 'rails_helper'

RSpec.describe Setting, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:key) }
    it { should validate_uniqueness_of(:key) }
    it { should validate_presence_of(:value) }
  end

  describe '.get' do
    it 'returns the value for a given key' do
      setting = FactoryBot.create(:setting, key: 'test_key', value: 'test_value')
      expect(Setting.get('test_key')).to eq('test_value')
    end

    it 'returns nil if key does not exist' do
      expect(Setting.get('nonexistent')).to be_nil
    end
  end

  describe '.set' do
    it 'creates a new setting if key does not exist' do
      Setting.set('new_key', 'new_value')
      expect(Setting.get('new_key')).to eq('new_value')
    end

    it 'updates existing setting' do
      FactoryBot.create(:setting, key: 'existing_key', value: 'old_value')
      Setting.set('existing_key', 'new_value')
      expect(Setting.get('existing_key')).to eq('new_value')
    end
  end

  describe '.auto_round_robin?' do
    it 'returns true when assignment_strategy is round_robin' do
      Setting.set('assignment_strategy', 'round_robin')
      expect(Setting.auto_round_robin?).to be_truthy
    end

    it 'returns false when assignment_strategy is not round_robin' do
      Setting.set('assignment_strategy', 'manual')
      expect(Setting.auto_round_robin?).to be_falsey
    end
  end
end
