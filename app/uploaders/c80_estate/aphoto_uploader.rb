Class C80Estate::AtphotoUploader < BaseFileUploader

# File 'app/uploaders/c80_estate/aphoto_uploader.rb', line 15

def store_dir
  "uploads/areas/#{model.id}"
end