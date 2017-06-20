require 'rails_helper'

RSpec.describe OffencesPresenter, type: :presenter do
  let(:detainee) { create(:detainee, offences: offences) }
  subject { described_class.new(detainee.offences) }

  describe '#empty?' do
    context 'when there are no offences' do
      let(:offences) { [] }

      specify { expect(subject.empty?).to be true }
    end

    context 'when there is at least one offence' do
      let(:offences) { build_list(:offence, rand(1..5))  }

      specify { expect(subject.empty?).to be false }
    end
  end

  describe '#any?' do
    context 'when there are no offences' do
      let(:offences) { [] }

      specify { expect(subject.any?).to be false }
    end

    context 'when there is at least one offence' do
      let(:offences) { build_list(:offence, rand(1..5))  }

      specify { expect(subject.any?).to be true }
    end
  end

  describe '#each' do
    context 'when there are no offences' do
      let(:offences) { [] }

      it 'returns an empty list' do
        expect(subject.each.to_a).to eq []
      end
    end

    context 'when there is at least one offence' do
      let(:offences) { build_list(:offence, rand(1..5))  }

      it 'returns a list of offences' do
        expect(subject.each.to_a).to eq offences
      end
    end
  end
end
