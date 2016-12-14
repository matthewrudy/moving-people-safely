class User < ApplicationRecord
  devise :database_authenticatable, :recoverable,
    :trackable, :validatable, :timeoutable,
    :omniauthable, omniauth_providers: [:mojsso]

  class << self
    def from_omniauth(auth)
      user = where(email: auth.info.email).first
      if user
        user.update_attributes(provider: auth.provider, uid: auth.uid)
      else
        user = first_or_create_by_uid_and_provider(auth)
      end
      user
    end

    private

    def first_or_create_by_uid_and_provider(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_create do |u|
        u.provider = auth.provider
        u.uid = auth.uid
        u.email = auth.info.email
        u.first_name = auth.info.first_name
        u.last_name = auth.info.last_name
        u.password = Devise.friendly_token[0, 20]
      end
    end
  end
end
