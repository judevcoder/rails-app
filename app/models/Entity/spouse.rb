class Spouse < PeopleAndFirm

  include ModelMethods

  default_scope{ where(class_name: "Spouse")}
  validates_presence_of :first_name, :last_name
  validates_length_of :first_name, :last_name, :email, :phone_number, maximum: 250
  validate :validate_my_percentage
  belongs_to :super_entity, class_name: "SuperEntity"
  belongs_to :entity

  def validate_my_percentage
    if self.my_percentage.blank?
      errors.add(:undivided_interest, "can not be blank")
      return
    end

    if self.my_percentage.to_f <= 0
      errors.add(:undivided_interest, "must be more than zero")
      return
    end

    if self.my_percentage.to_f >= self.remaining_share_or_interest_
      errors.add(:undivided_interest, "must be less than #{self.remaining_share_or_interest_} %")
      return
    end
  end

end