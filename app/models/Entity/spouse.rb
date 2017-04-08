class Spouse < PeopleAndFirm

  include ModelMethods

  default_scope{ where(class_name: "Spouse")}
  validates_presence_of :first_name, :last_name
  validates_length_of :first_name, :last_name, :email, :phone_number, maximum: 250
  belongs_to :super_entity, class_name: "SuperEntity"
  belongs_to :entity


end
