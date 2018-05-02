json.array! @recruitments do |recruitment|
  json.merge! recruitment.attributes
  json.participants recruitment.participants do |participant|
    json.merge! participant.attributes
  end
end
