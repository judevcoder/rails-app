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
end
