class CounteroffersController < ApplicationController

  def create
    @counteroffer = Counteroffer.new(counteroffer_params)
    if @counteroffer.save
      
    else
      
    end
  end

  def delete
    @counteroffer = Counteroffer.find(params[:id])
    @counteroffer.delete
    
  end

  def update
    @counteroffer = Counteroffer.find(params[:id])
    if @counteroffer.update(counteroffer_params)
      
    else
      
    end
  end

  def counteroffer_params
    params.permit(:offer_id, :offered_date, :offered_type, :offered_price)
  end
end
