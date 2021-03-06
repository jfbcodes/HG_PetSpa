class Human < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :pets, dependent: :destroy
  has_many :appointments, through: :pets

  before_validation :check_if_missing_password!

  def check_if_missing_password!
    if encrypted_password.nil? || encrypted_password.empty?
      new_password = (0...8).map { (65 + rand(26)).chr }.join
      self.password = new_password
      self.password_confirmation = new_password
    end
  end
end
