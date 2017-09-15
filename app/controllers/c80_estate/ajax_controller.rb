Class C80Estate::AjaxController < ActionController::Base

# File 'app/controllers/c80_estate/ajax_controller.rb', line 4

def get_atype_propnames

  atype_id = request.params[:atype_id]
  obj = Atype.get_propnames(atype_id)

  respond_to do |format|
    format.js { render json: obj, status: :ok }
    # format.json
  end
  
end
# File 'app/controllers/c80_estate/ajax_controller.rb', line 16
def areas_ecoef

  area_id = request.params[:area_id] == "" ? nil:request.params[:area_id]
  atype_id = request.params[:atype_id] == "" ? nil:request.params[:atype_id]
  start_date = request.params[:start_date] == "" ? nil:request.params[:start_date]
  end_date = request.params[:end_date] == "" ? nil:request.params[:end_date]

  obj = Sevent.ecoef(area_id: area_id,
                     start_date: start_date,
                     end_date: end_date,
                     atype_id: atype_id
  )

  respond_to do |format|
    format.js { render json: obj, status: :ok }
    # format.json
  end
end
# File 'app/controllers/c80_estate/ajax_controller.rb', line 35
def properties_busy_coef

  prop_id = request.params[:prop_id] == "" ? nil:request.params[:prop_id]
  start_date = request.params[:start_date] == "" ? nil:request.params[:start_date]
  atype_id = request.params[:atype_id] == "" ? nil:request.params[:atype_id]
  end_date = request.params[:end_date] == "" ? nil:request.params[:end_date]

  obj = Pstat.busy_coef(prop_id: prop_id,
                        start_date: start_date,
                        end_date: end_date,
                        atype_id: atype_id
  )

  respond_to do |format|
    format.js { render json: obj, status: :ok }
    # format.json
  end
  
end
# File 'app/controllers/c80_estate/ajax_controller.rb', line 55
def can_view_statistics_property

  @res = current_admin_user.can_view_statistics?

  respond_to do |format|
    format.js
    # format.json
  end
  
end
# File 'app/controllers/c80_estate/ajax_controller.rb', line 66
def can_view_statistics_area

  @res = current_admin_user.can_view_statistics?

  respond_to do |format|
    format.js
    # format.json
  end
  
end
# File 'app/controllers/c80_estate/ajax_controller.rb', line 77
def can_edit_area

  area_id = request.params[:area_id] == "" ? nil:request.params[:area_id]
  @res = false

  if area_id != ''
    @area = Area.find(area_id)
    @res = current_admin_user.can_edit_area?(@area)
  end

  respond_to do |format|
    format.js
    # format.json
  end
end