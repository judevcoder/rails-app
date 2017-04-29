class Entity < ApplicationRecord

  acts_as_paranoid

  include MyFunction

  class_attribute :basic_info_only
  validates_presence_of :date_of_formation
  validates_presence_of :first_name, :last_name , unless: :validation_for_names
  validates :name, presence: true, uniqueness: true,  allow_blank: false, if: :validation_for_names
  validates :email, email: true, if: "self.email.present?"
  # validate :phone_validation
  validates_length_of :name, maximum: 250
  validates_length_of :first_name, :last_name, :county, maximum: 250
  validate :ein_or_ssn_length_Corporation
  #validate :validate_number_of_assets
  validates_length_of :city2, maximum: 250, if: "self.city2.present?"
  validates_length_of :state2, maximum: 250, if: "self.state2.present?"
  validates_length_of :zip2, maximum: 250, if: "self.zip2.present?"
  validates_length_of :country, maximum: 250, if: "self.country.present?"
  validates_length_of :postal_address2, maximum: 250, if: "self.postal_address2.present?"
  validates_length_of :country2, maximum: 250, if: "self.country2.present?"
  validates_length_of :index, maximum: 250, if: "self.index.present?"
  validates_numericality_of :part, less_than_or_equal_to: 99, if: "self.part.present?"

  validate :check_uniqueness
  validate :valid_date_of_formation

  belongs_to :entity_type, class_name: "EntityType", foreign_key: "type_"
  belongs_to :property
  has_many :members, ->{where(class_name: "Member")}, class_name: "Member", foreign_key: "super_entity_id"
  has_many :stockholders, ->{where(class_name: "StockHolder")}, class_name: "StockHolder", foreign_key: "super_entity_id"
  has_one :judge, ->{where(class_name: "Judge")}, class_name: "Judge", foreign_key: "super_entity_id"
  has_one :guardian, ->{where(class_name: "Guardian")}, class_name: "Guardian", foreign_key: "super_entity_id"
  has_one :ward, ->{where(class_name: "Ward")}, class_name: "Ward", foreign_key: "super_entity_id"
  has_many :directors, ->{where(class_name: "Director")}, class_name: "Director", foreign_key: "super_entity_id"
  has_many :officers, ->{where(class_name: "Officer")}, class_name: "Officer", foreign_key: "super_entity_id"
  has_many :managers, ->{where(class_name: "Manager")}, class_name: "Manager", foreign_key: "super_entity_id"
  has_many :partners, ->{where(class_name: "Partner")}, class_name: "Partner", foreign_key: "super_entity_id"
  has_one :principal, ->{where(class_name: "Principal")}, class_name: "Principal", foreign_key: "super_entity_id"
  has_many :agents, ->{where(class_name: "Agent")}, class_name: "Agent", foreign_key: "super_entity_id"
  has_many :limited_partners, ->{where(class_name: "LimitedPartner")}, class_name: "LimitedPartner", foreign_key: "super_entity_id"
  has_many :general_partners, ->{where(class_name: "GeneralPartner")}, class_name: "GeneralPartner", foreign_key: "super_entity_id"
  has_many :settlors, ->{where(class_name: "Settlor")}, class_name: "Settlor", foreign_key: "super_entity_id"
  has_many :trustees, ->{where(class_name: "Trustee")}, class_name: "Trustee", foreign_key: "super_entity_id"
  has_many :beneficiaries, ->{where(class_name: "Beneficiary")}, class_name: "Beneficiary", foreign_key: "super_entity_id"
  has_many :tenants_in_common, ->{where(class_name: "TenantInCommon")}, class_name: "TenantInCommon", foreign_key: "super_entity_id"
  has_many :joint_tenants, ->{where(class_name: "JointTenant")}, class_name: "JointTenant", foreign_key: "super_entity_id"
  has_many :spouses, ->{where(class_name: "Spouse")}, class_name: "Spouse", foreign_key: "super_entity_id"

  after_save :add_key
  before_save :set_default_val, :trim_name

  class << self
    def USSTATES
      ["Delaware", "Nevada", "New York", "California", "Florida"] + ["Alabama", "Alaska", "Arizona", "Arkansas", "Colorado", "Connecticut", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "New Hampshire", "New Jersey", "New Mexico", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"].sort
    end
  end

  def remaining_
    if self.Corporation?
      self.number_of_share
    elsif self.LLP?
      self.partners.sum(:my_percentage)
    elsif self.LLC?
      self.total_membership_interest
    elsif self.Partnership?
      self.partners.sum(:my_percentage).try(:to_f) || 0
    elsif self.LimitedPartnership?
      (self.general_partners.sum(:my_percentage).try(:to_f) || 0) + (self.limited_partners.sum(:my_percentage).try(:to_f) || 0)
    elsif self.TenancyinCommon?
      self.total_undivided_interest
    end
  end

  def total
    self.number_of_assets
  end

  def remaining
    if self.members.take
      self.members.take.remaining_share_or_interest
    else
      remaining_
    end
  end

  def corporate_remaining_share
    val   = StockHolder.where(super_entity_id: self.id).sum(:stock_share).try(:to_i)
    val ||= 0
    (self.number_of_assets.to_i - val.to_i).to_i rescue nil
  end

  def corporate_distributed_share
    val   = StockHolder.where(super_entity_id: self.id).sum(:stock_share)
    val.to_i || 0
  end

  def self.TransactionEntity(etype="entity")
    if etype == "individual"
      a = Entity.where.not(name: [nil, ''], type_: 2..100).pluck(:name, :id, :type_)
      b = Entity.where("(name2 is null or name2 = '') and type_ = ?", 2).pluck(:name, :id, :type_)
    else
      a = Entity.where.not(name: [nil, ''], type_: [1,2]).pluck(:name, :id, :type_)
      b = Entity.where("name2 is not null and name2 <> '' and type_ = ?", 2).pluck(:name, :id, :type_)
    end
    MemberType.InitMemberTypes if MemberType.member_types.nil?
    return (a+b).uniq.map! {
        |item| ["#{item[0]} (#{MemberType.member_types[item[2]]})", item[1]]
    }
  end

  def self.PurchasedPropertyEntity
    MemberType.InitMemberTypes if MemberType.member_types.nil?
    Entity.where.not(name: [nil, ''], type_: [7,8,9]).pluck(:name, :id, :type_).map! {
        |item| ["#{item[0]} (#{MemberType.member_types[item[2]]})", item[1]]
    }
  end

  def self.TransactionEntityWithType(etype="entity")
    if etype == "individual"
      a = Entity.where.not(name: [nil, ''], type_: 2..100).pluck(:name, :id, :type_)
      b = Entity.where("(name2 is null or name2 = '') and type_ = ?", 2).pluck(:name, :id, :type_)
    else
      a = Entity.where.not(name: [nil, ''], type_: [1,2]).pluck(:name, :id, :type_)
      b = Entity.where("name2 is not null and name2 <> '' and type_ = ?", 2).pluck(:name, :id, :type_)
    end
    MemberType.InitMemberTypes if MemberType.member_types.nil?
    return (a+b).uniq.map! {
        |item| [item[0], item[1], item[2], "#{MemberType.member_types[item[2]]}"]
    }
  end

  def self.PurchasedPropertyEntityWithType
    MemberType.InitMemberTypes if MemberType.member_types.nil?
    Entity.where.not(name: [nil, ''], type_: [7,8,9]).pluck(:name, :id, :type_).map! {
        |item| [item[0], item[1], item[2], "#{MemberType.member_types[item[2]]}"]
    }
  end

  def display_name
    comma_str = ""
    comma_str = "," if self.has_comma
    "#{self.name.strip}#{comma_str} #{self.legal_ending}" #" #{(self.legal_ending.present? ? (self.legal_ending[0] == ',' ? self.legal_ending : ' ' + self.legal_ending) : '')}"
   end

   def trim_name
     self.name.strip!
   end

  private
  def ein_or_ssn_length_Corporation
    if self.Corporation?
      if self.ein_or_ssn.present?
        if self.ein_or_ssn.size != 9
          errors.add(:ein, " should be 9 characters")
          return
        end
        unless /\A([A-Za-z0-9]+)\Z/i.match(self.ein_or_ssn)
          errors.add(:ein, " is invalid")
        end
      end
    end
  end

  def validate_number_of_assets
    if self.Corporation?
      if self.number_of_assets.blank?
        errors.add(:total_stock_share, " can't be blank")
        return
      end
      if (self.number_of_assets.try(:to_f) || 0) <= 0
        errors.add(:total_stock_share, " enter more than zero")
        return
      end
      if (self.number_of_assets.try(:to_f) || 0) >= 99999999999
        errors.add(:total_stock_share, " enter more than zero")
        return
      end
    elsif self.SoleProprietorship? && (self.number_of_assets.try(:to_f) || 0) < 100
      errors.add(:total, " must be 100")
      return
    end
  end

  def set_default_val
    if self.LimitedPartnership? || self.LLC? || self.LLP? || self.Partnership? || self.Trust? || self.TenancyinCommon? || self.JointTenancy? || self.TenancyByTheEntirety?
      self.number_of_assets = 100
    end
  end

  def validation_for_names
    self.LLC? || self.LLP? || self.LimitedPartnership? || self.Corporation? || self.Partnership? || self.Trust? || self.power_of_attorney?
  end

  public

  def full_name
    "#{first_name} #{last_name}"
  end

  def name
    "#{super}"
  end

end
