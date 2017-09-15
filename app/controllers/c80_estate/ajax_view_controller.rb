Class C80Estate::AjaxViewController < ActionController::Base

# File 'app/controllers/c80_estate/ajax_view_controller.rb', line 4

def table_properties_coef_busy

  @atype_id = request.params[:atype_id] == "" ? nil:request.params[:atype_id]

  respond_to do |format|
    format.js
  end
end
# File 'app/controllers/c80_estate/ajax_view_controller.rb', line 13

def table_properties_coef_busy_sq

  @atype_id = request.params[:atype_id] == "" ? nil:request.params[:atype_id]

  respond_to do |format|
    format.js
  end
end