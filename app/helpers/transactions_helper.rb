module TransactionsHelper
    def get_sale_transaction_properties(trans_main_id)
        @transaction_main = TransactionMain.find(trans_main_id) 
        @transaction = @transaction_main.sale
        if @transaction.present? 
            transaction_property_ids = TransactionProperty.where(transaction_id: @transaction.id).pluck(:property_id) 
            properties = Property.where(id: transaction_property_ids) 
        else
            properties = nil
        end

        return properties
    end

    def get_buy_transaction_properties(trans_main_id)
        @transaction_main = TransactionMain.find(trans_main_id) 
        @transaction = @transaction_main.purchase
        if @transaction.present?
            transaction_property_ids = TransactionProperty.where(transaction_id: @transaction.id).pluck(:property_id) 
            properties = Property.where(id: transaction_property_ids)
        else
            properties = nil
        end 
        
        return properties
    end
end
