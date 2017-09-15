Class C80Estate::Area < ActiveRecord::Base

# File 'app/models/c80_estate/area.rb', line 44

def self.all_areas
  self.all
end

# File 'app/models/c80_estate/area.rb', line 48

def self.free_areas
  self.joins(:astatuses).where(:c80_estate_astatuses => {tag: 'free'})
end

# File 'app/models/c80_estate/area.rb', line 60

def self.free_areas_sq
  Rails.logger.debug "<Area.free_areas_sq>"
  sum = 0.0
  self.free_areas.each do |area|
    # area_prop_square = area.item_props.where(:prop_name_id => 9)
    area_prop_square = area.square_value
    sum += area_prop_square
  end
  Rails.logger.debug "<Area.free_areas_sq> sum = #{sum}"
  sum
end

# File 'app/models/c80_estate/area.rb', line 72

def self.busy_areas
  self.joins(:astatuses).where(:c80_estate_astatuses => {tag: 'busy'})
end

# File 'app/models/c80_estate/area.rb', line 77

def self.busy_areas_sq
  sum = 0.0
  self.busy_areas.each do |area|
    area_prop_square = area.item_props.where(:prop_name_id => 9)
    if area_prop_square.present?
      if area_prop_square.count > 0
        sum += area_prop_square.first.value.to_f
      end
    end
  end
  sum
end

# File 'app/models/c80_estate/area.rb', line 90

def self.all_areas_sq
  sum = 0.0
  self.all.each do |area|
    area_prop_square = area.item_props.where(:prop_name_id => 9)
    if area_prop_square.present?
      sum += area_prop_square.first.value.to_f
    end
  end
  sum
end

# File 'app/models/c80_estate/area.rb', line 101

def self.where_price_range(range)
  self.joins(:item_props)
      .where(c80_estate_item_props: {prop_name_id: 1})
      .where('c80_estate_item_props.value > ?', range.split(',')[0].to_f-1)
      .where('c80_estate_item_props.value < ?', range.split(',')[1].to_f+1)
end

# File 'app/models/c80_estate/area.rb', line 108

def self.where_square_range(range)
  C80Estate::Area.joins(:item_props)
      .where(c80_estate_item_props: {prop_name_id: 9})
      .where('c80_estate_item_props.value > ?', range.split(',')[0].to_f-1)
      .where('c80_estate_item_props.value < ?', range.split(',')[1].to_f+1)
end

# File 'app/models/c80_estate/area.rb', line 115

def self.where_oenter(v)
  # Rails.logger.debug "\t\t [2]: v = #{v}"
  r = C80Estate::Area.joins(:item_props)
          .where(c80_estate_item_props: {prop_name_id: 8})
  if v.to_i == 11
    r = r.where(c80_estate_item_props: {value: 1})
  else
    r = r.where.not(c80_estate_item_props: {value: 1})
  end
  r
end

# File 'app/models/c80_estate/area.rb', line 127

def self.where_floor(v)
  # Rails.logger.debug "\t\t [2]: v = #{v}"
  C80Estate::Area.joins(:item_props)
      .where(c80_estate_item_props: {prop_name_id: 5})
      .where(c80_estate_item_props: {value: v})
end

# File 'app/models/c80_estate/area.rb', line 134

def self.where_assigned_person_id(id)
  # Rails.logger.debug "\t\t [2]: v = #{v}"
  C80Estate::Area.joins(:property)
      .where(:c80_estate_properties => {assigned_person_id: id})
end

# File 'app/models/c80_estate/area.rb', line 140

def self.import_excel(file)

  Rails.logger.debug "------------------------------------------------------------- self.import [BEGIN] "

  import_result = ''
  spreadsheet = open_spreadsheet(file)
  header = spreadsheet.row(1)

  # Rails.logger.debug(header)
  # ["title", "atype", "square", "price", "status"]

  (2..spreadsheet.last_row).each do |i|

    row = Hash[[header, spreadsheet.row(i)].transpose]

    Rails.logger.debug("---------- #{row} -----------")
    # {"title"=>"С2-1.18", "atype"=>"Торговое помещение", "square"=>"0", "price"=>800.0, "status"=>"Занята"}

    #   area_where = Area.where(:slug => row["ID"])
    #   if area_where.count > 0
    #
    #     area = Area.where(:slug => row["ID"]).first
    #     puts "--- Обновляем данные для #{area.id}, #{area.slug}: "
    #     puts "--- Хотим вставить данные: " + row.to_hash.to_s
    #     area.price = row["Цена"]
    #     area.space = row["Площадь"]
    #     area.save
    #     puts "."
    #
    #   else
    #     s = "В базе не найден павильон: #{row.to_hash}"
    #     import_result += s + "\n"
    #     puts s
    #
    #   end
    #
    #

    area = C80Estate::Area.create!({
                                       title: row['title'],
                                       property_id: row['property_id'].to_i,
                                       atype_id: row['atype_id'].to_i,
                                       owner_type: 'AdminUser',
                                       owner_id: 2,
                                       assigned_person_type: 'AdminUser',
                                       assigned_person_id: 2
                                   })

    C80Estate::ItemProp.create!([
                                    {value: row['price'].to_f, area_id: area.id, prop_name_id: 1},
                                    {value: row['square'].to_f, area_id: area.id, prop_name_id: 9},
                                ])

    area.astatuses << C80Estate::Astatus.find(row['astatus'].to_i)
    area.save

  end

  puts "------------------------------------------------------------- self.import [END] "
  import_result

end

# File 'app/models/c80_estate/area.rb', line 203

def self.where_atype(atype_id)
  self.where(:atype_id => atype_id)
end

# File 'app/models/c80_estate/area.rb', line 272

def has_astatus?
  errors.add_to_base 'Укажите статус площади' if self.astatuses.blank?
end

# File 'app/models/c80_estate/area.rb', line 278

def atype_title
  atype.title
end

# File 'app/models/c80_estate/area.rb', line 282

def property_title
  property.title
end

# File 'app/models/c80_estate/area.rb', line 286

def astatus_title
  astatuses.first.title
end

# File 'app/models/c80_estate/area.rb', line 290

def astatus_id
  astatuses.first.id
end

# File 'app/models/c80_estate/area.rb', line 294

def astatus_tag
  astatuses.first.tag
end

# File 'app/models/c80_estate/area.rb', line 301

def square_value_to_s
  s = 0
  if self.square_value.present?
    s = self.square_value
  end
  s.to_s(:rounded, precision: 2)
end

# File 'app/models/c80_estate/area.rb', line 310

def price_value_to_s
  s = 0
  if self.price_value.present?
    s = self.price_value
  end
  s.to_s(:rounded, precision: 2)
end

# File 'app/models/c80_estate/area.rb', line 319

def power_price_value_to_s
  s = 0
  if self.power_price_value.present?
    s = self.power_price_value
  end
  s.to_s(:rounded, precision: 2)
end

# File 'app/models/c80_estate/area.rb', line 327

def is_free?
  astatus_tag == 'free'
end

# File 'app/models/c80_estate/area.rb', line 331

def is_busy?
  astatus_tag == 'busy'
end

# File 'app/models/c80_estate/area.rb', line 335

def assigned_person_title
  res = '-'
  if property.assigned_person.present?
    res = property.assigned_person.email
  end
  res
end

# File 'app/models/c80_estate/area.rb', line 343

def owner_id
  res = -1
  if owner.present?
    res = owner.id
  end
  res
end

# File 'app/models/c80_estate/area.rb', line 351

def last_updater_title
  if last_updater.present?
    last_updater.email
  end
end

# File 'app/models/c80_estate/area.rb', line 357

def main_image_url
  url = "no_thumb_#{atype.id}.jpg"

  if aphotos.count > 0
    url = aphotos.first.image.thumb512
  end
  url
end

# File 'app/models/c80_estate/area.rb', line 367

def is_locked_area_price?
  res = false
  pa = item_props.where(:prop_name_id => 14)
  if pa.count > 0
    pa_val = pa.first.value.to_f
    if pa_val > 0
      res = true
    end
  end
  res
end

# File 'app/models/c80_estate/area.rb', line 381

def recalc_price
  calc_price_value
end

# File 'app/models/c80_estate/area.rb', line 387

def recalc_square
  calc_square_value
end

# File 'app/models/c80_estate/area.rb', line 392

def recalc_power_price_value
  calc_power_price_value
end

# File 'app/models/c80_estate/area.rb', line 398

def recalc_all
  recalc_square
  recalc_price
  recalc_power_price_value
end