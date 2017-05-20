class PropertyOffersController < ApplicationController

  respond_to :json

  def create
    @property_offer = PropertyOffer.new(property_offer_params)
    if @property_offer.save
      render json: {status: true, offer_id: @property_offer.id}
    else
      render json: {status: false}
    end
  end

  def destroy
    @property_offer = PropertyOffer.find(params[:id])
    if @property_offer.destroy
      render json: true
    else
      render json: false
    end
    
  end

  def update
    @property_offer = PropertyOffer.find(params[:id])
    if @property_offer.update(property_offer_params)
      render json: true
    else
      render json: false
    end
  end

  def property_offer_params
    params.permit(:offer_name, :property_id, :is_accepted, :accepted_counteroffer_id)
  end
end
