class Contact < ApplicationRecord
  
  acts_as_paranoid
  
  validates_presence_of :first_name, :last_name, :email
  validate :email_check
  
  ROLE = ["Counter-Party",
          "Counter-Party Broker or Agent",
          "Counter-Party Legal",
          "Counter-Party Consultant",
          "Tenant",
          "Tenant Broker or Agent",
          "Tenant Legal",
          "Tenant Consultant",
          "Lendor",
          "Lendor Broker or Agent",
          "Lendor Legal",
          "Lendor Consultant",
          "Environmental Consultant",
          "Surveyor",
          "Zoning Consultant",
          "Title Company",
          "Qualified Intermediary",
          "Legal Consultant",
          "Accountant",
          "Other Consultant"]
  
  def self.prospective_entity
    where("company_role != ? OR client_type is NULL", "Counter-Party")
  end  
  
  def self.prospective_person
    where(company_role: "Counter-Party")
  end  
  
  # Views
  def name
    "#{self.first_name} #{self.last_name}"
  end

  private
  
  def email_check
    if self.email.present? && !self.email.email?
      errors.add(:email, ' is invalid !')
    end
  end


end
