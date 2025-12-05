class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         authentication_keys: [:login]

  validates :login, presence: true, uniqueness: true
  validates_format_of :login, with: URI::MailTo::EMAIL_REGEXP

  alias_attribute :email, :login
end
