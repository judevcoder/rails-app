class RentTable < ApplicationRecord
  belongs_to :property

  def format_year
    "#{self.start_year} - #{self.end_year}"
  end

  def format_rent
    "$ #{self.rent}"
  end
end
