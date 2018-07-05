require 'feature_helper'

RSpec.feature 'filling in a PER from a police station', type: :feature do
  let(:offences_data) {
    {
      offences: [
        { name: 'Burglary', case_reference: 'Ref 3064' },
        { name: 'Attempted murder', case_reference: 'Ref 7291' }
      ]
    }
  }

  scenario 'adding a new escort and filling it in' do
    banbury_police_station = create(:police_custody, name: 'Banbury Police Station')

    login_options = { sso: { info: { permissions: [{'organisation' => User::POLICE_ORGANISATION}]}} }
    login(nil, login_options)

    expect(current_path).to eq select_police_station_path

    select_police_station.select_station('Banbury Police Station')

    expect(current_path).to eq root_path

    move_data = build(:move, from_establishment: banbury_police_station)
    escort = build(:escort, move: move_data)
    healthcare_data = build(:healthcare, :with_medications, escort: escort)
    risk_data = build(:risk, :from_police, escort: escort)
    detainee = build(:detainee, gender: 'female')
    create(:magistrates_court, name: move_data.to)

    dashboard.click_start_a_per

    search.search_pnc_number(detainee.pnc_number)
    search.click_start_new_per

    detainee_details.complete_form(detainee, :police)

    move_details.complete_form(move_data)

    escort_page.confirm_move_info(move_data)
    escort_page.confirm_detainee_details(detainee)
    escort_page.click_edit_risk

    risk.complete_forms(risk_data)
    risk_summary.confirm_risk_details(risk_data)
    risk_summary.confirm_and_save

    escort_page.click_edit_healthcare

    healthcare.complete_forms(healthcare_data)
    healthcare_summary.confirm_healthcare_details(healthcare_data)
    healthcare_summary.confirm_and_save

    escort_page.click_edit_offences

    offences.complete_form(offences_data)

    escort_page.confirm_offence_details(offences_data)

  end
end
