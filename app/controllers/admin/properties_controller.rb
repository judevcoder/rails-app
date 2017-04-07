class Admin::PropertiesController < Admin::AdminController

  def resource_class_with_condition
    Property
  end

end