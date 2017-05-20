class Counteroffer < ApplicationRecord
  belongs_to :property_offer, foreign_key: :property_offer_id

end
