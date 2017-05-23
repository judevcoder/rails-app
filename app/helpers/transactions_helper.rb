module TransactionsHelper
    def get_transaction_properties(trans_main_id, property_type = 'sale')
        if property_type == 'sale'
            is_sale = true
        elsif property_type == 'purchase'
            is_sale = false
            else
                is_sale = 'undefined'
        end
        
        if is_sale != 'undefined'
            transaction_property_ids = TransactionProperty.where(transaction_main_id: trans_main_id, is_sale: is_sale).pluck(:property_id)
            properties = Property.where(id: transaction_property_ids).order(created_at: :desc)
        else
            properties = nil 
        end
        
        return properties
    end

    def get_property_step(property_id, trans_main_id, is_sale = true)
        cur_step = TransactionProperty.where(property_id: property_id).where(transaction_main_id: trans_main_id).where(is_sale: is_sale).first

        return cur_step
    end

    def get_property(property_id)
        return Property.find(property_id)
    end
    
    def get_recent_counteroffer_price(transaction_property_offer)
        last_offered_price = transaction_property_offer.counteroffers.where("offered_price IS NOT NULL AND offered_date IS NOT NULL").order(updated_at: :asc).last.try(:offered_price)
        if last_offered_price
            return number_to_currency(last_offered_price)
        else
            return ""
        end
    end
    
    def is_property_closed?(transaction_id, property_id)
      retVal = false
      p = TransactionProperty.where(transaction_id: transaction_id, property_id: property_id).first
      retVal = p.closed? if !p.nil?
      return retVal
    end

    def is_property_in_contract?(transaction_id, property_id)
      retVal = false
      p = TransactionProperty.where(transaction_id: transaction_id, property_id: property_id).first
      if p.present?
        p.transaction_property_offers.where(is_accepted: :true)
      end
      return retVal
    end
    
end
