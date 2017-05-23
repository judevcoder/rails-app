class TransactionPropertyOffersController < ApplicationController

  respond_to :json

  def create
    @property_offer = TransactionPropertyOffer.new(transaction_property_offer_params)
    if @property_offer.save
      render json: {status: true, offer_id: @property_offer.id, offer_name: @property_offer.offer_name }
    else
      render json: {status: false}
    end
  end

  def destroy
    @property_offer = TransactionPropertyOffer.find(params[:id])
    if @property_offer.destroy
      render json: true
    else
      render json: false
    end
    
  end

  def update
    @property_offer = TransactionPropertyOffer.find(params[:id])
    if @property_offer.update(transaction_property_offer_params)
      render json: { status: true, offer_name: @property_offer.offer_name }
    else
      render json: { status: false }
    end
  end

  def transaction_property_offer_params
    params.permit(:offer_name, :transaction_property_id, :is_accepted, :accepted_counteroffer_id)
  end
end
