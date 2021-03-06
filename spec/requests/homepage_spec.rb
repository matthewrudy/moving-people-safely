require 'rails_helper'

RSpec.describe 'Homepage', type: :request do
  before { sign_in create(:user) }

  describe "#show" do
    context "with no search params" do
      before { get '/' }

      it "responds with a 200 code" do
        expect(response.status).to eql 200
      end
    end

    context "with valid search params" do
      before { get '/?prison_number=A1234AB' }

      it "responds with a 200 code" do
        expect(response.status).to eql 200
      end
    end

    context "with invalid search params" do
      before { get '/?prison_number=FAIL' }

      it "responds with a 200 code" do
        expect(response.status).to eql 200
      end
    end
  end

  describe "#escorts" do
    before do
      post "/escorts/search",
        params: {
          escorts_due_on: date
        }
    end

    let(:date) { '01/02/2003' }

    context "with a valid date" do
      it "redirects to root path with the appropriate params" do
        expect(response).to redirect_to "/"
      end

      it "sets the escorts due on param in the session" do
        expect(session[:escorts_due_on]).to eq(date)
      end
    end
  end
end
