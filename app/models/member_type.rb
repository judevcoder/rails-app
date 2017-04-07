class MemberType < ApplicationRecord

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :members

  def custom_order
    objects = []
    ["Individual", "Sole Proprietorship", "Power of Attorney", "Guardianship", "Estate", "Trust", "Tenancy in Common",
     "Joint Tenancy with Rights of Survivorship (JTWROS)", "Tenancy by the Entirety", "Partnership", "LLC", "LLP",
     "Limited Partnership", "Corporation"].each do |name|
      objects << MemberType.find_or_create_by(name: name)
    end
    objects
  end

  def getCorporationId
    MemberType.find_or_create_by(name: "Corporation").id
  end

  def getLLCId
    MemberType.find_or_create_by(name: "LLC").id
  end

  def getLLPId
    MemberType.find_or_create_by(name: "LLP").id
  end

  def getPartnershipId
    MemberType.find_or_create_by(name: "Partnership").id
  end

  def getLimitedPartnershipId
    MemberType.find_or_create_by(name: "Limited Partnership").id
  end

  def getSoleProprietorshipId
    MemberType.find_or_create_by(name: "Sole Proprietorship").id
  end

  def getEstateId
    MemberType.find_or_create_by(name: "Estate").id
  end

  def getTrustId
    MemberType.find_or_create_by(name: "Trust").id
  end

  def getGuardianshipId
    MemberType.find_or_create_by(name: "Guardianship").id
  end

  def getTenancyinCommonId
    MemberType.find_or_create_by(name: "Tenancy in Common").id
  end

  def getJointTenancyId
    MemberType.find_or_create_by(name: "Joint Tenancy with Rights of Survivorship (JTWROS)").id
  end

  def getTenancyByTheEntiretyId
    MemberType.find_or_create_by(name: "Tenancy by the Entirety").id
  end

  def get_power_of_attorney_id
    MemberType.find_or_create_by(name: "Power of Attorney").id
  end
  
  def getIndividualId
    MemberType.find_or_create_by(name: "Individual").id
  end
end
