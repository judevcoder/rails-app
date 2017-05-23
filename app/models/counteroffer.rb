class Counteroffer < ApplicationRecord
  belongs_to :property_offer, foreign_key: :transaction_property_offer_id

end
