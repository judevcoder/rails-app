class TenantInCommon < PeopleAndFirm

  include ModelMethods

  default_scope{ where(class_name: "TenantInCommon")}
  validates_presence_of :first_name, :last_name
  validates_length_of :first_name, :last_name, :email, :phone_number, maximum: 250
  validate :validate_my_percentage
  belongs_to :super_entity, class_name: "SuperEntity"
  belongs_to :entity

  attr_accessor :share_error

  def validate_my_percentage

    if self.remaining_share_or_interest_ <= 0
      errors.add(:share_error, "now remaining is Zero")
      return
    end

    if self.my_percentage.blank?
      errors.add(:undivided_interest, "can not be blank")
      return
    end

    if self.my_percentage.to_f <= 0
      errors.add(:undivided_interest, "must be more than zero")
      return
    end

    if self.my_percentage.to_f > self.remaining_share_or_interest_
      errors.add(:undivided_interest, "must be less than or equal to #{self.remaining_share_or_interest_} %")
      return
    end

  end

end
