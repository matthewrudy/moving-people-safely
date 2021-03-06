FactoryBot.define do
  factory :establishment do
    name     { "Establishment #{Faker::Number.number(3)}" }
    nomis_id { "#{Faker::Lorem.characters(2)}I".upcase }
    sso_id   { "#{Faker::Lorem.characters(6)}.noms.moj".downcase }
  end

  factory :crown_court, parent: :establishment do
    type { 'CrownCourt' }
  end

  factory :magistrates_court, parent: :establishment do
    type { 'MagistratesCourt' }
  end

  factory :prison, parent: :establishment do
    type { 'Prison' }
  end

  factory :police_custody, parent: :establishment do
    type { 'PoliceCustody' }
  end

  factory :immigration_removal_centre, parent: :establishment do
    type { 'ImmigrationRemovalCentre' }
  end

  factory :youth_secure_estate, parent: :establishment do
    type { 'YouthSecureEstate' }
  end
end
