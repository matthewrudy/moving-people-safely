require 'feature_helper'

RSpec.feature 'filling in a PER from a prison', type: :feature do
  let(:offences_data) do
    {
      offences: [
        { name: 'Burglary', case_reference: 'Ref 3064' },
        { name: 'Attempted murder', case_reference: 'Ref 7291' }
      ]
    }
  end

  let(:establishment_sso_id) { 'bedford.prisons.noms.moj' }
  let(:establishment_nomis_id) { 'BDI' }
  let(:prison) { create(:prison, name: 'HMP Bedford', sso_id: establishment_sso_id, nomis_id: establishment_nomis_id) }
  let(:login_options) { { sso: { info: { permissions: [{ 'organisation' => establishment_sso_id }] } } } }
  let(:valid_body) { { establishment: { code: establishment_nomis_id } }.to_json }
  let(:detainee) { build(:detainee) }
  let(:move_data) { build(:move, from_establishment: prison) }
  let(:escort) { build(:escort, move: move_data) }
  let(:healthcare_data) { build(:healthcare, :with_medications, escort: escort) }
  let(:risk_data) { build(:risk, :with_high_csra, escort: escort) }

  before do
    stub_nomis_api_request(:get, "/offenders/#{detainee.prison_number}", status: 404)
    stub_nomis_api_request(:get, "/offenders/#{detainee.prison_number}/image", status: 404)
    stub_nomis_api_request(:get, "/offenders/#{detainee.prison_number}/charges", status: 404)
    stub_nomis_api_request(:get, "/offenders/#{detainee.prison_number}/location", body: valid_body)

    create(:magistrates_court, name: move_data.to)
  end

  scenario 'adding a new escort and filling it in' do
    login(nil, login_options)

    dashboard.click_start_a_per

    search.search_prison_number(detainee.prison_number)
    search.click_start_new_per

    detainee_details.complete_form(detainee)

    move_details.complete_form(move_data)

    escort_page.confirm_move_info(move_data)
    escort_page.confirm_detainee_details(detainee)
    escort_page.click_edit_risk

    risk.complete_forms(risk_data)
    risk_summary.confirm_risk_details(risk_data)
    risk_summary.confirm_and_save

    escort_page.click_edit_offences

    offences.complete_form(offences_data)

    escort_page.confirm_offence_details(offences_data)

    click_button 'Sign out'

    login_options = { sso: { info: { permissions: [{ 'organisation' => establishment_sso_id, 'roles' => ['healthcare'] }] } } }
    login(nil, login_options)

    dashboard.click_start_a_per

    search.search_prison_number(detainee.prison_number)
    search.click_continue_per

    escort_page.click_edit_healthcare

    healthcare.complete_forms(healthcare_data)
    healthcare_summary.confirm_healthcare_details(healthcare_data)
    healthcare_summary.confirm_and_save

    escort_page.confirm_offences_action_link('View')
    escort_page.confirm_risk_action_link('View')
    escort_page.confirm_healthcare_labels(:prison)
  end

  scenario 'completing a PER with a blank detainee (bug fix)' do
    # Emulate what happens in EscortsController#create with NOMIS down
    create(:escort,
      :with_no_offences,
      prison_number: detainee.prison_number,
      move: Move.new(from_establishment: prison),
      detainee: Detainee.new(prison_number: detainee.prison_number)
    )

    login(nil, login_options)

    # User finds the PER with the blank detainee
    dashboard.click_start_a_per

    search.search_prison_number(detainee.prison_number)
    search.click_continue_per

    # System now presents detainee form because detainee is blank.
    # System used to wrongly think detainee was fully present and:
    # 1. present move form;
    # 2. throw an error after Save and continue was clicked due to
    #    AgeCalculator being passed nil date as show escort tried to display
    #    detainee partial.
    detainee_details.complete_form(detainee)

    move_details.complete_form(move_data)

    escort_page.confirm_move_info(move_data)
    escort_page.confirm_detainee_details(detainee)
    escort_page.click_edit_risk

    risk.complete_forms(risk_data)
    risk_summary.confirm_risk_details(risk_data)
    risk_summary.confirm_and_save

    escort_page.click_edit_offences

    offences.complete_form(offences_data)

    escort_page.confirm_offence_details(offences_data)

    click_button 'Sign out'
  end
end
