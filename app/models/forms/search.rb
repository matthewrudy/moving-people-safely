module Forms
  class Search
    include ActiveModel::Validations
    include ActiveModel::Conversion

    PRISON_NUMBER_REGEX = /\A[a-z]\d{4}[a-z]{2}\z/i
    POLICE_NUMBER_REGEX = /\d{2}\/\d{6}[a-z]\z/i

    attr_accessor :prison_number, :pnc_number

    validates :prison_number,
      format: { with: PRISON_NUMBER_REGEX },
      if: :prison_number

    validates :pnc_number,
      format: { with: POLICE_NUMBER_REGEX },
      if: :pnc_number

    def initialize(search = {})
      @prison_number = search[:prison_number]&.upcase
      @pnc_number = search[:pnc_number]&.upcase
    end

    def identifier
      prison_number || pnc_number
    end

    def identifier_type
      return 'PNC number' if pnc_number
      'prison number'
    end

    def persisted?
      false
    end
  end
end
