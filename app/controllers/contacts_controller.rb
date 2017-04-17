class ContactsController < ApplicationController
  before_action :current_page

  def new
    @contact = Contact.new
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/contacts\">Contacts </a></h4></div>".html_safe
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/contacts/new\">Add #{(params[:contact_type] || "contact").titleize} </a></h4></div>".html_safe
    render layout: false, template: "contacts/new" if request.xhr?
  end
  
  def create
    @contact = Contact.new(contact_params)
    @contact.role = "Counter-Party"
    if @contact.contact_type == "Client Participant"
      @contact.role = @contact.cp_role
    elsif @contact.contact_type == "Personnel"
      @contact.role = @contact.per_role
    end
    
    respond_to do |format|
      if @contact.save
        format.html { redirect_to contacts_path }
        format.js {render layout: false, template: "contacts/new"}
      else
        format.html { render action: 'new' }
        format.js {render layout: false, template: "contacts/new"}
      end
    end
  end
  
  def index
    @contacts = Contact.with_deleted
    @contacts = @contacts.where(deleted_at: nil) unless params[:trashed].to_b
    @contacts = @contacts.where.not(deleted_at: nil) if params[:trashed].to_b
    @contacts = @contacts.order(created_at: :desc).paginate(page: params[:page], per_page: sessioned_per_page)
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/contacts\">Contacts </a></h4></div>".html_safe
    add_breadcrumb "<div class=\"pull-left\"><h4><a href=\"/contacts/new\"> List </a></h4></div>".html_safe
  end
  
  def multi_delete
    common_multi_delete
  end

  private
  
  def current_page
    @current_page = 'contacts'
  end

  
  def contact_params
    params.require(:contact).permit!
  end

end
