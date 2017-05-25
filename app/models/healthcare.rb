class Healthcare < ApplicationRecord
  belongs_to :escort
  include Questionable
  act_as_assessment :healthcare

  StatusChangeError = Class.new(StandardError)

  delegate :not_started?, :needs_review?, :incomplete?, :unconfirmed?, :confirmed?, to: :healthcare_workflow
  delegate :current_establishment, to: :escort, allow_nil: true

  has_many :medications, dependent: :destroy

  def default_contact_number
    current_establishment&.default_healthcare_contact_number
  end

  def status
    healthcare_workflow&.status
  end

  def confirm!(user:)
    status_change(:confirm_with_user!, user: user)
  end

  def not_started!
    status_change(:not_started!)
  end

  def unconfirmed!
    status_change(:unconfirmed!)
  end

  def incomplete!
    status_change(:incomplete!)
  end

  private

  def move
    escort&.move
  end

  def healthcare_workflow
    move&.healthcare_workflow
  end

  def status_change(method, *args)
    raise(StatusChangeError, method) unless healthcare_workflow
    healthcare_workflow.public_send(method, *args)
  end
end
