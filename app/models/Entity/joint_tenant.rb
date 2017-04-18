class JointTenant < PeopleAndFirm

  include ModelMethods

  default_scope{ where(class_name: "JointTenant")}
  validates_presence_of :first_name, :last_name
  validates_length_of :first_name, :last_name, :email, :phone_number, maximum: 250
  validate :validate_my_percentage
  belongs_to :super_entity, class_name: "SuperEntity"
  belongs_to :entity

  attr_accessor :share_error

  def validate_my_percentage

    if self.remaining_share_or_interest_ <= 0
      errors.add(:share_error, "now remaining is Zero")
      return false
    end

    if self.my_percentage.blank?
      errors.add(:undivided_interest, "can not be blank")
      return false
    end

    if self.my_percentage.to_f <= 0
      errors.add(:undivided_interest, "must be more than zero")
      return false
    end

    if self.my_percentage.to_f == self.total_remaining_share_or_interest
      errors.add(:undivided_interest, " can not be 100%")
      return false
    end

    if self.my_percentage.to_f > self.remaining_share_or_interest_
      errors.add(:undivided_interest, "must be less than or equal to #{self.remaining_share_or_interest_} %")
      return false
    end

  end

  def name
    if self.entity.present?
      self.entity.name
    else
      "#{self.first_name} #{self.last_name}"
    end
  end

end
