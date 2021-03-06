require 'rails_helper'

RSpec.describe 'custom date formats', type: :config do
  describe 'default date format' do
    it 'returns a date in the format DD/MM/YYYY' do
      example_date = Date.civil(1940, 3, 10)
      expect(example_date.to_s).to eq '10/03/1940'
    end
  end

  describe 'humanized date format' do
    it 'returns a date in the format DD MM YYYY' do
      example_date = Date.civil(1940, 3, 10)
      expect(example_date.to_s(:humanized)).to eq '10 Mar 1940'
    end
  end

  describe 'humanized time format' do
    it 'returns a time in the format HH:MM | DD MM YYYY' do
      example_time = DateTime.civil(1940, 3, 10, 12, 30)
      expect(example_time.to_s(:humanized)).to eq '12:30 | 10 Mar 1940'
    end
  end
end
