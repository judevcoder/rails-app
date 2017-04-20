class Trustee < PeopleAndFirm

  include ModelMethods

  default_scope{ where(class_name: "Trustee")}
  validate :entity_presence
  # validates_presence_of :first_name, :last_name
  validates_length_of :first_name, :last_name, :email, :phone_number, maximum: 250
  belongs_to :super_entity, class_name: "SuperEntity"
  belongs_to :entity

  def entity_presence
    unless self.is_person?
      if self.entity.blank?
        errors.add(:entity, "is invalid, Please add it before saving")
        return
      end
    end
  end

end