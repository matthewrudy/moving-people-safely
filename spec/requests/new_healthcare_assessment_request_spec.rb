require 'rails_helper'

RSpec.describe 'New healthcare assessment requests', type: :request do
  let(:prison_number) { 'A1234BC' }
  let(:detainee) { create(:detainee, prison_number: prison_number) }
  let(:escort) { create(:escort, prison_number: prison_number, detainee: detainee) }

  context 'when user is not autenticated' do
    it 'redirects the user to the login page' do
      get "/escorts/#{escort.id}/healthcare/new"
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(new_session_path)
    end
  end

  context 'when user is autenticated' do
    before { sign_in create(:user) }

    context 'but the escort with provided id does not exist' do
      it 'raises a record not found error' do
        expect {
          get "/escorts/#{SecureRandom.uuid}/healthcare/new"
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'but there is no detainee details for the PER' do
      let(:escort) { create(:escort) }

      it 'redirects the user back to the escort page' do
        get "/escorts/#{escort.id}/healthcare/new"
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(escort_path(escort))
      end
    end

    context 'but there is already a healthcare assessment for the escort' do
      let(:healthcare) { create(:healthcare) }
      let(:escort) { create(:escort, prison_number: prison_number, detainee: detainee, healthcare: healthcare) }

      it 'redirects the user back to the escort page' do
        get "/escorts/#{escort.id}/healthcare/new"
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(escort_healthcare_path(escort))
      end
    end
  end
end
