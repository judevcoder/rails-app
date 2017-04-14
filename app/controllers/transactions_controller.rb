class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :edit, :update, :destroy, :edit_qualified_intermediary,
                                         :qualified_intermediary, :properties_edit, :properties_update,
                                         :terms, :terms_update, :personnel, :personnel_update, :get_status, :set_status]
  before_action :current_page
  before_action :add_breadcrum  
  # GET /project
  # GET /project.json
  def index
    klazz         = (params[:mode] == 'buy') ? 'TransactionPurchase' : 'TransactionSale'
    @transactions = klazz.constantize.with_deleted.joins(:transaction_main)
    @transactions = @transactions.where('transaction_mains.init' => false, 'transaction_mains.user_id' => current_user.id)
    @transactions = @transactions.where('transactions.deleted_at' => nil) unless params[:trashed].to_b
    @transactions = @transactions.where.not('transactions.deleted_at' => nil) if params[:trashed].to_b
    @transactions = @transactions.order('transactions.created_at DESC').paginate(page: params[:page], per_page: sessioned_per_page)
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/transactions\">List </a></h4></div>".html_safe
  end
  
  # GET /project/1
  # GET /project/1.json
  def show
    @properties = @transaction.properties.order(id: :asc)
  end
  
  # GET /project/new
  def new
    if params[:transaction_type] == '1031 Still Selling' || params[:type] == 'purchase'
      
      @transaction_main = TransactionMain.find_by(id: params[:main_id]) || TransactionMain.create(user_id: current_user.id, init: true)
      
      @transaction = if params[:type] == 'purchase'
                       t = TransactionSale.where(transaction_main_id: @transaction_main.id).first
                       t1 = TransactionPurchase.new({
                         transaction_main_id: @transaction_main.id,
                         relinquishing_seller_entity_id: t.relinquishing_seller_entity_id,
                         relinquishing_seller_honorific: t.relinquishing_seller_honorific,
                         relinquishing_seller_first_name: t.relinquishing_seller_first_name,
                         relinquishing_seller_last_name: t.relinquishing_purchaser_last_name,
                         replacement_purchaser_entity_id: t.replacement_purchaser_entity_id,
                         replacement_purchaser_honorific: t.replacement_purchaser_honorific,
                         replacement_purchaser_first_name: t.replacement_seller_first_name,
                         replacement_purchaser_last_name: t.replacement_purchaser_last_name,
                         purchaser_person_is: t.seller_person_is
                       })   
                       t1.save
                       t1                  
                     else
                       TransactionSale.new(transaction_main_id: @transaction_main.id)
                     end
      
      @transaction.is_purchase = (params[:type] == 'sale' || params[:type].blank?) ? 0 : 1
      @transaction.prop_owner = @transaction.replacement_seller_contact_id || 0
      @transaction.prop_status = "Prospective Purchase"
    
    elsif params[:transaction_type] == '1031 Already Sold'
      @transaction_main        = TransactionMain.create(user_id: current_user.id, init: true, purchase_only: true)
      @transaction             = TransactionPurchase.new(transaction_main_id: @transaction_main.id)
      @transaction.is_purchase = 1
    elsif params[:type] == 'sale' && params[:main_id].present?
      @transaction_main        = TransactionMain.find_by(id: params[:main_id])
      t = TransactionPurchase.where(transaction_main_id: @transaction_main.id).first
      @transaction = TransactionSale.new({
        transaction_main_id: @transaction_main.id,
        relinquishing_seller_entity_id: t.relinquishing_seller_entity_id,
        relinquishing_seller_honorific: t.relinquishing_seller_honorific,
        relinquishing_seller_first_name: t.relinquishing_seller_first_name,
        relinquishing_seller_last_name: t.relinquishing_purchaser_last_name,
        replacement_purchaser_entity_id: t.replacement_purchaser_entity_id,
        replacement_purchaser_honorific: t.replacement_purchaser_honorific,
        replacement_purchaser_first_name: t.replacement_seller_first_name,
        replacement_purchaser_last_name: t.replacement_purchaser_last_name,
        seller_person_is: t.purchaser_person_is
      })   
      @transaction.save
      @transaction.is_purchase = 0
    end
  end
  
  # GET /project/1/edit
  def edit
    
  end
  
  # GET /Transaction/1/properties_edit
  def properties_edit
    if params["type"] == "sale"
      @transaction.prop_owner = @transaction.relinquishing_seller_entity_id || 0
      @transaction.prop_status = "Purchased"      
    else
      @transaction.prop_owner = @transaction.replacement_seller_contact_id || 0
      @transaction.prop_status = "Prospective Purchase"
    end    
    if @transaction.transaction_properties.blank?
      @transaction.transaction_properties.build
    end
    @transaction.entity_info = @transaction.seller_name || @transaction.purchaser_name
  end
  
  # GET /Transaction/1/properties_update
  def properties_update
    pid = params[:transaction][:transaction_properties_attributes]["0".to_sym][:property_id]
    flag = false
    
    if !(params["type"]).nil? && params["type"] == "purchase" && @transaction.replacement_seller_contact_id.nil? 
      property = Property.where(id: pid).first
      if !property.owner_entity_id.nil?
        contact = Contact.where(id: property.owner_entity_id).first
        @transaction.replacement_seller_contact_id = contact.id
        @transaction.replacement_seller_first_name = contact.company_name || contact.first_name
        @transaction.replacement_seller_last_name = contact.last_name
        flag = true
      end
    end 

    begin
      TransactionSale.transaction do 
        @transaction.save! if flag
        @transaction.update!(transaction_property_params)
      end
      return redirect_to personnel_transaction_path(@transaction, sub: 'personnel', type: params[:type], main_id: params[:main_id])
    rescue Exception => e  
     render action: :properties_edit
    end
    
  end
  
  # POST /project
  # POST /project.json
  def create
    @transaction         = params[:transaction_klazz].constantize.new(transaction_params)
    @transaction_main    = @transaction.transaction_main
    @transaction.user_id = current_user.id
    purchase = params[:is_purchase] || "false"
    
    if purchase == "true"
      if @transaction.seller_person_is == false 
        @transaction.replacement_seller_contact_id = @transaction.rplmnt_seller_contact_id
      end
      if @transaction.purchaser_person_is == false 
        @transaction.replacement_purchaser_entity_id = @transaction.rplmnt_purchaser_entity_id
      end
      if @transaction.replacement_seller_contact_id
        seller = Contact.where(id: @transaction.replacement_seller_contact_id).first
        if seller 
          @transaction.replacement_seller_first_name = seller.first_name
          @transaction.replacement_seller_last_name = seller.last_name
        end
      end
      if @transaction.replacement_purchaser_entity_id
        purchaser = Entity.where(id: @transaction.replacement_purchaser_entity_id).first
        if purchaser 
          @transaction.replacement_purchaser_honorific = purchaser.honorific
          @transaction.replacement_purchaser_first_name = purchaser.first_name || purchaser.name
          @transaction.replacement_purchaser_last_name = purchaser.last_name
          # Mirror the replacement buyer to relinquishing seller
          @transaction.relinquishing_seller_entity_id = purchaser.id
          @transaction.relinquishing_seller_honorific = purchaser.honorific
          @transaction.relinquishing_seller_first_name = purchaser.first_name || purchaser.name
          @transaction.relinquishing_seller_last_name = purchaser.last_name
        end
      end 
    else
      if @transaction.seller_person_is == false 
        @transaction.relinquishing_seller_entity_id = @transaction.relqn_seller_entity_id
      end
      if @transaction.purchaser_person_is == false 
        @transaction.relinquishing_purchaser_contact_id = @transaction.relqn_purchaser_contact_id
      end
      if @transaction.relinquishing_seller_entity_id
        seller = Entity.where(id: @transaction.relinquishing_seller_entity_id).first
        if !seller.nil?
          @transaction.relinquishing_seller_honorific = seller.honorific
          @transaction.relinquishing_seller_first_name = seller.first_name || seller.name
          @transaction.relinquishing_seller_last_name = seller.last_name
          # Mirror the relinquishing seller to replacement buyer
          @transaction.replacement_purchaser_entity_id = seller.id
          @transaction.replacement_purchaser_honorific = seller.honorific
          @transaction.replacement_purchaser_first_name = seller.first_name || seller.name
          @transaction.replacement_purchaser_last_name = seller.last_name
        end        
      end
      if @transaction.relinquishing_purchaser_contact_id
        purchaser = Contact.where(id: @transaction.relinquishing_purchaser_contact_id).first
        if purchaser 
          @transaction.relinquishing_purchaser_first_name = purchaser.first_name
          @transaction.relinquishing_purchaser_last_name = purchaser.last_name
        end
      end 
    end
    respond_to do |format|
      if @transaction.save
        AccessResource.add_access({ user: current_user, resource: @transaction })
        @transaction.transaction_main.update_column(:init, false)
        # format.html { redirect_to edit_transaction_path(@transaction, type: @transaction.get_sale_purchase_text, main_id: @transaction.transaction_main, status_alert: (CGI.escape(params[:status_alert]) rescue nil)), notice: 'Transaction was successfully created.' }
        format.html { redirect_to properties_edit_transaction_path(@transaction, sub: 'property', type: @transaction.get_sale_purchase_text, main_id: @transaction_main.id, status_alert: (CGI.escape(params[:status_alert]) rescue nil)), notice: 'Transaction was successfully created.' }
        format.json { render action: 'show', status: :created, location: @transaction }
      else
        format.html { render action: 'new' }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PATCH/PUT /project/1
  # PATCH/PUT /project/1.json
  def update
    @transaction = params[:transaction_klazz].constantize.find(params[:id])
    if @transaction.update(transaction_params)
      redirect_to terms_transaction_path(@transaction, sub: 'terms', type: @transaction.get_sale_purchase_text, main_id: @transaction_main.id) 
    else
      render action: :edit
    end
  end
  
  # DELETE /project/1
  # DELETE /project/1.json
  def destroy
    @transaction_main.destroy
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end
  
  def settings
    @transaction = TransactionSale.find_by(key: params[:id])
    render layout: false
  end
  
  def edit_qualified_intermediary
    @qualified_intermediary = @transaction.qualified_intermediary
    @qualified_intermediary.wired_instruction
    @qualified_intermediary.contact
  end
  
  def qualified_intermediary
    @qualified_intermediary = @transaction.qualified_intermediary
    if @qualified_intermediary.update(qualified_intermediary_params)
      # redirect_to edit_qualified_intermediary_transaction_path(@transaction, sub: params[:sub], main_id: params[:main_id], type: params[:type])
      redirect_to properties_edit_transaction_path(@transaction, sub: 'property', type: params[:type], main_id: params[:main_id])
    else
      render action: :edit_qualified_intermediary
    end
  end
  
  def terms
    if @transaction.transaction_term.blank?
      @transaction.build_transaction_term
    end
  end
  
  def terms_update
    if @transaction.update(transaction_terms_params)
      # redirect_to terms_transaction_path(@transaction, sub: params[:sub], main_id: params[:main_id], type: params[:type])
      redirect_to edit_qualified_intermediary_transaction_path(@transaction, sub: 'qi', type: params[:type], main_id: params[:main_id])
    else
      render action: :terms
    end
  end
  
  def personnel
    if @transaction.transaction_personnel.blank?
      @transaction.create_transaction_personnel
    end
    @transaction.transaction_personnel.create_contacts
    @transaction_personnel = @transaction.transaction_personnel
  end
  
  def personnel_update
    @transaction_personnel = @transaction.transaction_personnel
    if @transaction.transaction_personnel.update(transaction_personnels_params)
      if TransactionPersonnel::FIXED_TITLE.find_next(params[:sub_sub] || TransactionPersonnel::FIXED_TITLE.first)
        redirect_to personnel_transaction_path(@transaction, sub: params[:sub], sub_sub: TransactionPersonnel::FIXED_TITLE.find_next(params[:sub_sub] || TransactionPersonnel::FIXED_TITLE.first), main_id: params[:main_id], type: params[:type])
      else
        redirect_to personnel_transaction_path(@transaction, sub: params[:sub], sub_sub: TransactionPersonnel::FIXED_TITLE.last, main_id: params[:main_id], type: params[:type])
      end
    else
      render action: :personnel
    end
  end
  
  def get_status
  
  end
  
  def set_status
    if @transaction_main.update(transaction_main_params)
      redirect_to get_status_transaction_path(@transaction_main, main_id: params[:main_id], type: params[:type])
    else
      render action: :get_status
    end
  end
  
  def multi_delete
    common_multi_delete
  end
  
  private
  # Use callbacks to share common setup or constraints between actions.
  def set_transaction
    @transaction_main = TransactionMain.find(params[:main_id])
    for_sale_or_purchase_tab
  end
  
  def for_sale_or_purchase_tab
    if params[:type].blank? || params[:type] == 'sale'
      @transaction = @transaction_main.sale
    else
      @transaction = @transaction_main.purchase
    end
  end
  
  # Never trust parameters from the scary internet, only allow the white list through.
  def transaction_params
    params.require(:transaction).permit!
  end
  
  def qualified_intermediary_params
    params.require(:qualified_intermediary).permit(:name, :currently_held, :price,
                                                   :premises_address, :city, :state, :country, :seller,
                                                   :seller_entity_type, :due_diligence_period, :wired_instruction_attributes => [:bank, :aba_no, :credit_to, :account_number, :reference, :id],
                                                   :contact_attributes                                                       => [:first_name, :last_name, :email, :zip, :fax, :street_address, :city, :state, :phone1, :phone2, :id])
  end
  
  def transaction_property_params
    params.require(:transaction).permit(transaction_properties_attributes: [:property_id, :sale_price, :id, :_destroy])
  end
  
  def transaction_terms_params
    params.require(:transaction).permit(transaction_term_attributes: [:id, :purchase_price, :cap_rate, :psa_date, :m_psa_date, :first_deposit_date_due, :m_first_deposit_date_due,
                                                                      :first_deposit, :inspection_period_days, :end_of_inspection_period_note,
                                                                      :second_deposit, :second_deposit_amount, :closing_date, :m_closing_date, :transaction_id, :second_deposit_date_due, :m_second_deposit_date_due])
  end
  
  def transaction_personnels_params
    params.require(:transaction).permit(:contacts_attributes => [:first_name, :last_name, :email, :zip, :fax, :street_address, :city, :state, :phone1, :phone2, :id, :object_title])
  end
  
  def transaction_main_params
    params.require(:transaction_main).permit!
  end
  
  private
  def current_page
    @current_page = 'project'
  end
  
  def add_breadcrum
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/transactions\">Transactions </a></h4></div>".html_safe
  end
end
