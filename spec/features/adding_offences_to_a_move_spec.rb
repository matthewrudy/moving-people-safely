require 'feature_helper'

RSpec.feature 'Adding offences to a move', type: :feature do
  let(:prison_number) { 'A45345DQ' }
  let(:detainee) { create(:detainee, :with_no_offences, prison_number: prison_number) }
  let(:move) { create(:move, :active) }
  let(:escort) { create(:escort, prison_number: prison_number, detainee: detainee, move: move) }
  let(:fixture_json_file_path) { Rails.root.join('spec', 'support', 'fixtures', 'valid-nomis-charges.json') }
  let(:valid_json) { File.read(fixture_json_file_path) }

  let(:expected_offences) {
    [
      { name: "Attempt burglary dwelling with intent to inflict grievous bodily harm (CR: T20117495)" },
      { name: "Abstract / use without authority electricity (CR: T20117495)" }
    ]
  }

  before do
    login
    visit escort_path(escort)
  end

  scenario 'saving pre populated offences' do
    stub_nomis_api_request(:get, "/offenders/#{detainee.prison_number}/charges", body: valid_json)

    escort_page.click_edit_offences
    offences.save_and_continue
    escort_page.confirm_offences(expected_offences)
  end

  let(:expected_offences_after_ammendment) {
    [
      { name: "Updated text (CR: NEW_REFERENCE)" },
      { name: "Abstract / use without authority electricity (CR: T20117495)" },
      { name: "Some other description (CR: ANOTHER_REFERENCE)" }
    ]
  }

  scenario 'ammending pre populated offences' do
    stub_nomis_api_request(:get, "/offenders/#{detainee.prison_number}/charges", body: valid_json)

    escort_page.click_edit_offences
    offences.update(index: 0, description: "Updated text", case_reference: "NEW_REFERENCE")
    offences.add(description: "Some other description", case_reference: "ANOTHER_REFERENCE")
    offences.save_and_continue
    escort_page.confirm_offences(expected_offences_after_ammendment)
  end

  let(:expected_offences_after_failure) {
    [
      { name: "Manually adding an offence (CR: YET_ANOTHER_REFERENCE)" }
    ]
  }

  scenario 'saving an offence after pre populating offences fails' do
    stub_nomis_api_request(:get, "/offenders/#{detainee.prison_number}/charges", status: 500)

    escort_page.click_edit_offences
    offences.confirm_api_unavailable_warning
    offences.update(index: 0, description: "Manually adding an offence", case_reference: "YET_ANOTHER_REFERENCE")
    offences.save_and_continue
    escort_page.confirm_offences(expected_offences_after_failure)
  end
end