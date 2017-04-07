class Manager < PeopleAndFirm

  include MyFunction

  default_scope{ where(class_name: "Manager")}
  validates_presence_of :first_name, :last_name
  validates :email, email: true, if: "self.email.present?"
  validates_length_of :first_name, :last_name, :email, :postal_address, :fax, :phone1, :phone2, :city, :state, :zip, maximum: 250
  after_save :add_key

  belongs_to :entity
  belongs_to :super_entity, class_name: "SuperEntity"

end
