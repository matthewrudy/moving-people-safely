module Forms
  class Search < Forms::Base
    include ::ActiveModel::Conversion

    SearchModel = Struct.new(:prison_number, :id, :persisted?)

    def initialize(*)
      super SearchModel.new(nil, nil, false)
    end

    PRISON_NUMBER_REGEX = /\A[a-z]\d{4}[a-z]{2}\z/i

    property :prison_number, type: String

    validates :prison_number,
      presence: true,
      format: { with: PRISON_NUMBER_REGEX }

    def detainee
      @_detainee ||= ::Detainee.find_by(_at[:prison_number].matches(prison_number)) if valid?
    end

    private

    def _at
      ::Detainee.arel_table
    end
  end
end
