json.array! @recruitments do |recruitment|
  json.merge! recruitment.attributes
  json.participants recruitment.participants do |participant|
    json.id participant.id
    json.name participant.user.name
    json.discord_id participant.user.discord_id
  end
end
