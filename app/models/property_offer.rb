class PropertyOffer < ApplicationRecord
  belongs_to :property, primary_key: :property_id
  has_many :counteroffers, foreign_key: :property_offer_id, dependent: :destroy
  
end
