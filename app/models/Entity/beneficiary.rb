class Beneficiary < PeopleAndFirm

  include ModelMethods

  default_scope{ where(class_name: "Beneficiary")}
  validate :entity_presence
  validates_presence_of :first_name, :last_name
  validates_length_of :first_name, :last_name, :email, :phone_number, maximum: 250
  validate :remaining_share_or_interest_check
  belongs_to :super_entity, class_name: "SuperEntity"
  belongs_to :entity
  validate :validate_my_percentage

  def entity_presence
    unless self.is_person?
      if self.entity.blank?
        errors.add(:entity, "is invalid, Please add it before saving")
        return
      end
    end
  end

  def validate_my_percentage
    if self.my_percentage.blank?
      errors.add(:beneficiary_interest, "can not be blank")
      return
    end

    if self.my_percentage.to_f <= 0
      errors.add(:beneficiary_interest, "must be more than zero")
      return
    end

    if self.my_percentage.to_f >= self.remaining_share_or_interest_
      errors.add(:beneficiary_interest, "must be less than #{self.remaining_share_or_interest_} %")
      return
    end

  end

  def name
    "#{self.first_name} #{self.last_name}"
  end

end