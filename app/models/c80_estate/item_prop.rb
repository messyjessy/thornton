Class C80Estate::ItemProp < ActiveRecord::Base

# File 'app/models/c80_estate/item_prop.rb', line 10

def save(*args)
  super
rescue ActiveRecord::RecordNotUnique => error
  # post.errors[:base] << "You can only have one photo be your header photo"
  false
end

# File 'app/models/c80_estate/item_prop.rb', line 17

def self.all_uniq_values(prop_name_id)
  r = self.where(prop_name_id: prop_name_id)
      .map { |ip| ip.value.to_i }.uniq
  # Rails.logger.debug("<ItemProp.all_uniq_values> #{prop_name_id}: #{r}")
  r
end

