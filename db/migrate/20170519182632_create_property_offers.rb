class CreatePropertyOffers < ActiveRecord::Migration[5.0]
  def change
    create_table :property_offers do |t|
      t.string :offer_name
      t.integer :property_id
      t.boolean :is_accepted
      t.integer :accepted_counteroffer_id

      t.timestamps
    end
  end
end
