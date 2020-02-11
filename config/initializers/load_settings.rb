Dir.glob(Rails.root.join("config", "resources", "*.yml")).each do |file|
  Settings.add_source!(file)
end
Settings.reload!
