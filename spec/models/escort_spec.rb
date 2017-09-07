require 'rails_helper'

RSpec.describe Escort do
  it { should have_attached_file(:document) }
  it { should validate_attachment_content_type(:document).allowing('application/pdf') }

  describe 'default scope' do
    it 'returns only the escorts that have not been deleted' do
      create_list(:escort, 2)
      create(:escort, deleted_at: 1.hour.ago)
      expect(described_class.unscoped.count).to eq(3)
      expect(described_class.count).to eq(2)
    end
  end

  specify { is_expected.to have_one(:risk) }
  specify { is_expected.to have_one(:healthcare) }

  it { is_expected.to delegate_method(:offences).to(:detainee) }
  it { is_expected.to delegate_method(:surname).to(:detainee).with_prefix(true) }
  it { is_expected.to delegate_method(:forenames).to(:detainee).with_prefix(true) }
  it { is_expected.to delegate_method(:full_name).to(:canceller).with_prefix(true) }
  it { is_expected.to delegate_method(:date).to(:move).with_prefix(true) }

  describe '#completed?' do
    let(:risk) { create(:risk) }
    let(:healthcare) { create(:healthcare) }
    let(:detainee) { create(:detainee) }
    let(:move) { create(:move) }
    let(:escort) { create(:escort, detainee: detainee, move: move, risk: risk, healthcare: healthcare) }

    specify {
      escort = create(:escort, :completed)
      expect(escort).to be_completed
    }

    context 'when detainee info is not complete' do
      let(:detainee) { create(:detainee, surname: nil) }
      specify { expect(escort).not_to be_completed }
    end

    context 'when move info is not complete' do
      let(:move) { create(:move, date: nil) }
      specify { expect(escort).not_to be_completed }
    end

    context 'when risk assessment is not complete' do
      let(:risk) { create(:risk, :incomplete) }
      specify { expect(escort).not_to be_completed }
    end

    context 'when healthcare assessment is not complete' do
      let(:healthcare) { create(:healthcare, :incomplete) }
      specify { expect(escort).not_to be_completed }
    end

    context 'when offences info is not complete' do
      let(:detainee) { create(:detainee, :with_incompleted_offences) }
      specify { expect(escort).not_to be_completed }
    end
  end

  describe '#cancelled?' do
    context 'for a newly created escort' do
      let(:escort) { create(:escort) }
      specify { expect(escort).not_to be_cancelled }
    end

    context 'when the escort has been cancelled' do
      let(:escort) { create(:escort, cancelled_at: 1.day.ago) }
      specify { expect(escort).to be_cancelled }
    end
  end

  describe '#editable?' do
    context 'when is already issued' do
      let(:escort) { create(:escort, :issued) }
      specify { expect(escort).not_to be_editable }
    end

    context 'when is already cancelled' do
      let(:escort) { create(:escort, :cancelled) }
      specify { expect(escort).not_to be_editable }
    end

    context 'when is not cancelled or issued' do
      let(:escort) { create(:escort) }
      specify { expect(escort).to be_editable }
    end
  end

  describe '#cancel!' do
    let(:escort) { create(:escort) }
    let(:user) { create(:user) }
    let(:reason) { 'Started by mistake' }

    context 'when the escort is already cancelled' do
      let(:cancel_date) { 3.days.ago }
      let(:escort) { create(:escort, cancelled_at: cancel_date) }

      it 'raises an AlreadyCancelledError' do
        expect { escort.cancel!(user, reason) }.to raise_error(Escort::AlreadyCancelledError)
      end

      it 'keeps the current cancel date' do
        expect { escort.cancel!(user, reason) rescue nil }
          .not_to change { escort.reload.cancelled_at.to_i }.from(cancel_date.to_i)
      end
    end

    context 'when the escort is already issued' do
      let(:issued_date) { 3.days.ago }
      let(:escort) { create(:escort, issued_at: issued_date) }

      it 'raises an AlreadyIssuedError' do
        expect { escort.cancel!(user, reason) }.to raise_error(Escort::AlreadyIssuedError)
      end

      it 'keeps the current issued date' do
        expect { escort.issue! rescue nil }
          .not_to change { escort.reload.issued_at.to_i }.from(issued_date.to_i)
      end
    end

    context 'when the escort is not cancelled or issued yet' do
      let(:escort) { create(:escort) }

      it 'marks the escort as cancelled' do
        time = Time.now.utc
        expect { escort.cancel!(user, reason) }
          .to change { escort.reload.cancelled_at }.from(nil)
        expect(escort.cancelled_at).to be >= time
      end

      it 'stores the reason and the user who cancelled it' do
        escort.cancel!(user, reason)
        expect(escort.canceller).to eq user
        expect(escort.cancelling_reason).to eq reason
      end
    end
  end


  describe '#issued?' do
    context 'for a newly created escort' do
      let(:escort) { create(:escort) }
      specify { expect(escort).not_to be_issued }
    end

    context 'when the escort has been issued' do
      let(:escort) { create(:escort, issued_at: 1.day.ago) }
      specify { expect(escort).to be_issued }
    end
  end

  describe '#issue!' do
    let(:escort) { create(:escort) }

    context 'when the escort is already issued' do
      let(:issued_date) { 3.days.ago }
      let(:escort) { create(:escort, issued_at: issued_date) }

      it 'raises an AlreadyIssuedError' do
        expect { escort.issue! }.to raise_error(Escort::AlreadyIssuedError)
      end

      it 'keeps the current issued date' do
        expect { escort.issue! rescue nil }
          .not_to change { escort.reload.issued_at.to_i }.from(issued_date.to_i)
      end
    end

    context 'when the escort is not issued yet' do
      let(:escort) { create(:escort) }

      it 'marks the escort as issued' do
        time = Time.now.utc
        expect { escort.issue! }
          .to change { escort.reload.issued_at }.from(nil)
        expect(escort.issued_at).to be >= time
      end
    end
  end

  describe '#needs_review!' do
    context 'when is already in review' do
      let(:escort) { create(:escort, :needs_review) }

      it 'leaves the escort as needing reviewing' do
        expect { escort.needs_review! }
          .not_to change { escort.reload.needs_review? }.from(true)
      end
    end

    context 'when is not in review' do
      let(:escort) { create(:escort, :completed) }

      it 'marks the escort as needs reviewing' do
        expect { escort.needs_review! }
          .to change { escort.reload.needs_review? }.from(false).to(true)
      end
    end
  end

  describe '#needs_review?' do
    let(:detainee) { create(:detainee) }
    let(:risk) { create(:risk) }
    let(:healthcare) { create(:healthcare) }
    let(:escort) { create(:escort, detainee: detainee, risk: risk, healthcare: healthcare) }

    specify { expect(escort.needs_review?).to be_falsey }

    context 'when risk assessment needs reviewing' do
      let(:risk) { create(:risk, :needs_review) }

      specify { expect(escort.needs_review?).to be_truthy }
    end

    context 'when healthcare assessment needs reviewing' do
      let(:healthcare) { create(:healthcare, :needs_review) }

      specify { expect(escort.needs_review?).to be_truthy }
    end

    context 'when offences needs reviewing' do
      let(:detainee) { create(:detainee, :with_needs_review_offences) }

      specify { expect(escort.needs_review?).to be_truthy }
    end
  end

  describe '#current_establishment' do
    subject(:escort) { described_class.new }

    it 'returns the current establishment the prisoner is at' do
      expect(escort.current_establishment).to be_instance_of(Establishment)
    end
  end
end
