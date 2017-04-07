class TransactionProperty < ApplicationRecord

  belongs_to :transaction_sale, primary_key: :transaction_id
  belongs_to :transaction_purchase, primary_key: :transaction_id
  belongs_to :property

  delegate :name, to: :property, allow_nil: true

end
