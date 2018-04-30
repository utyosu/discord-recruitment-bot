json.array! @recruitments do |recruitment|
  json.id recruitment.id
  json.content recruitment.content
  json.expired_at recruitment.expired_at
  json.author_discord_id recruitment.author_discord_id
  json.label_id recruitment.label_id
  json.participants recruitment.participants do |participant|
    json.id participant.id
    json.discord_id participant.discord_id
    json.name participant.name
  end
end
