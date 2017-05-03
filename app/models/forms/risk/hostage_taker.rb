module Forms
  module Risk
    class HostageTaker < Forms::Base
      optional_field :hostage_taker, default: 'unknown'

      validate :valid_hostage_taker_options, if: proc { |f| f.hostage_taker == 'yes' }

      def valid_hostage_taker_options
        unless selected_hostage_taker_options.any?
          errors.add(:base, :minimum_one_option, options: hostage_taker_options.join(', '))
        end
      end

      optional_checkbox :staff_hostage_taker
      optional_checkbox :prisoners_hostage_taker
      optional_checkbox :public_hostage_taker

      reset attributes: %i[
        staff_hostage_taker date_most_recent_staff_hostage_taker_incident
        prisoners_hostage_taker date_most_recent_prisoners_hostage_taker_incident
        public_hostage_taker date_most_recent_public_hostage_taker_incident
      ], if_falsey: :hostage_taker

      property :date_most_recent_staff_hostage_taker_incident, type: TextDate
      reset attributes: %i[date_most_recent_staff_hostage_taker_incident],
            if_falsey: :staff_hostage_taker,
            enabled_value: true

      validates :date_most_recent_staff_hostage_taker_incident,
        date: { not_in_the_future: true },
        if: -> { hostage_taker == 'yes' && staff_hostage_taker == true }

      property :date_most_recent_prisoners_hostage_taker_incident, type: TextDate
      reset attributes: %i[date_most_recent_prisoners_hostage_taker_incident],
            if_falsey: :prisoners_hostage_taker,
            enabled_value: true

      validates :date_most_recent_prisoners_hostage_taker_incident,
        date: { not_in_the_future: true },
        if: -> { hostage_taker == 'yes' && prisoners_hostage_taker == true }

      property :date_most_recent_public_hostage_taker_incident, type: TextDate
      reset attributes: %i[date_most_recent_public_hostage_taker_incident],
            if_falsey: :public_hostage_taker,
            enabled_value: true

      validates :date_most_recent_public_hostage_taker_incident,
        date: { not_in_the_future: true },
        if: -> { hostage_taker == 'yes' && public_hostage_taker == true }

      private

      def selected_hostage_taker_options
        [staff_hostage_taker, prisoners_hostage_taker, public_hostage_taker]
      end

      def hostage_taker_options
        translate_options(%i[staff_hostage_taker prisoners_hostage_taker public_hostage_taker], :hostage_taker)
      end
    end
  end
end
