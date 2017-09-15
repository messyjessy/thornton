Class C80Estate::Property < ActiveRecord::Base

# File 'app/models/c80_estate/property.rb', line 26

def self.sorted_chart
  self.all.sort_by(&:busy_coef).reverse!
end

# File 'app/models/c80_estate/property.rb', line 31

def last_known_stats(atype_id: nil)
  pstats.where(:atype_id => atype_id).ordered_by_created_at.last
end

# File 'app/models/c80_estate/property.rb', line 36

def busy_coef(atype_id: nil)
  # необходимо обратиться к самому последнему (общему?) событию Pstat
  pstats.where(:atype_id => atype_id).ordered_by_created_at.last.coef_busy
end

# File 'app/models/c80_estate/property.rb', line 42

def busy_coef_sq(atype_id: nil)
  # необходимо обратиться к самому последнему (общему?) событию Pstat
  pstats.where(:atype_id => atype_id).ordered_by_created_at.last.coef_busy_sq
end

# File 'app/models/c80_estate/property.rb', line 48

def self.areas_count
  ac = 0
  self.all.each do |prop|
    ac += prop.areas.count
  end
  ac
end

# File 'app/models/c80_estate/property.rb', line 57

def self.average_price(atype_id: nil)

  res = 0.0
  sum = 0.0

  c = self.all.count
  if c > 0
    self.all.each do |prop|
      if prop.average_price.present?
        sum += prop.average_price(atype_id: atype_id)
      end
    end
    res = sum / c
  end

  res
end

# File 'app/models/c80_estate/property.rb', line 77

def self.average_price_busy(atype_id: nil)

  res = 0.0
  sum = 0.0

  c = self.all.count
  if c > 0
    self.all.each do |prop|
      if prop.average_price_busy.present?
        sum += prop.average_price_busy(atype_id: atype_id)
      end
    end
    res = sum / c
  end

  res
end

# File 'app/models/c80_estate/property.rb', line 98

def self.where_assig_user(user)
  if user.can_create_properties?
    C80Estate::Property.all
  else
    C80Estate::Property.where(:assigned_person_id => user.id)
  end

end

# File 'app/models/c80_estate/property.rb', line 107

def average_price(atype_id: nil)

  if atype_id.nil?
    ars = areas.all
  else
    ars = areas.where_atype(atype_id)
  end

  price_sum = 0.0

  ars.each do |area|
    if area.price_value.present?
      price_sum += area.price_value
    end
  end

  if ars.count != 0
    price_sum*1.0 / ars.count
  else
    0.0
  end

end

# File 'app/models/c80_estate/property.rb', line 133

def average_price_busy(atype_id: nil)

  if atype_id.nil?
    ars = areas.all
  else
    ars = areas.where_atype(atype_id)
  end

  busy_areas_count = 0
  price_sum = 0.0

  ars.each do |area|
    if area.is_busy?
      busy_areas_count += 1
      if area.price_value.present?
        price_sum += area.price_value
      end
    end
  end

  if busy_areas_count != 0
    price_sum*1.0 / busy_areas_count
  else
    0.0
  end

end

# File 'app/models/c80_estate/property.rb', line 161

def assigned_person_title
  res = "-"
  if assigned_person.present?
    res = assigned_person.email
  end
  res
end

# File 'app/models/c80_estate/property.rb', line 169

def owner_title
  res = "-"
  if owner.present?
    res = owner.email
  end
  res
end

# File 'app/models/c80_estate/property.rb', line 178

def logo_path
  url = 'property_default_logo.png'
  if plogos.count > 0
    url = plogos.first.image.thumb256
  end
  url
end

# File 'app/models/c80_estate/property.rb', line 186

def main_image_url
  url = 'no_thumb.png'
  if pphotos.count > 0
    url = pphotos.first.image.thumb512
  end
  url
end

# File 'app/models/c80_estate/property.rb', line 194

def last_updater
  res = '-'
  if pstats.count > 0
    res = pstats.last.sevent.auser.email
  end
end

# File 'app/models/c80_estate/property.rb', line 201

def square_value
  sum = 0.0
  areas.all.each do |area|
    if area.square_value.present?
      sum += area.square_value
    end
  end
  sum
end

# File 'app/models/c80_estate/property.rb', line 211

def power_price_value
  sum = 0.0
  areas.all.each do |area|
    if area.power_price_value.present?
      sum += area.power_price_value
    end
  end
  sum
end