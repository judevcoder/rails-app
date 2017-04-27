class Officer < ApplicationRecord

  belongs_to :entity

  include MyFunction

  # validate :phone_validation
  validates_presence_of :person_type, :office, :first_name, :last_name
  validates :email, email: true, if: "self.email.present?"
  validates_length_of :office, :first_name, :last_name, :email, :postal_address, :fax, :phone1, :phone2, :city, :state, :zip, maximum: 250
  after_save :add_key

end
