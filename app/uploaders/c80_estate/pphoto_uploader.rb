Class C80Estate::PphotoUploader < BaseFileUploader

# File 'app/uploaders/c80_estate/pphoto_uploader.rb', line 15

def store_dir
  "uploads/properties/#{model.id}"
end