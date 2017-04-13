class Contact < ApplicationRecord
  
  acts_as_paranoid
  
  validates_presence_of :first_name, :last_name, :email
  validate :email_check

  attr_accessor :name
  
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

  def self.TransactionContacts(company=false)
    if company 
      @contacts = Contact.where('company_role ilike ? and company_name is not null', "Counter-Party")
    else
      @contacts = Contact.where('company_role ilike ? and company_name is null', "Counter-Party")
    end   
    #@contacts = Contact.where('company_role ilike ? ', "Counter-Party")
    ret = []
    @contacts.each { |contact|
      contact.name = contact.try(:company_name) || ""
      if contact.name.blank?
        contact.name = contact.first_name + ' ' + contact.last_name
      end
      ret.push([contact.name, contact.id])
    }
    return ret
  end


end
