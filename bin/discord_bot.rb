require 'discordrb'
require 'json'
require 'net/http'
puts ENV['DISCORD_BOT_TOKEN']
$bot = Discordrb::Commands::CommandBot.new ({
  token: ENV['DISCORD_BOT_TOKEN'],
  client_id: ENV['DISCORD_BOT_CLIENT_ID'],
  prefix:'/',
  #log_mode: :debug,
})

$bot.message do |event|
  if event.kind_of?(Discordrb::Events::MessageEvent)
    get_message(event)
  end
end

$bot.command :list do |event|
  a = get_recruitments
  puts a
  recruitment_message = a.map{|recruitment|
    "#{recruitment['content']}"
  }.join("\n")
  event.send_message("```#{recruitment_message}```")
end

def get_recruitments
  uri = URI.parse("http://localhost:3000/api/recruitments")
  json = Net::HTTP.get(uri)
  JSON.parse(json)
end

def get_message(message_event)
  if message_event.content =~ /[@＠][0-9０１２３４５６７８９]+|募集/
    message = message_event.content
    user = message_event.author.username
    message_event.send_message("```\n#{user} : #{message}\n```")
  end
end

def test
  c= $bot.channel("437242889328918533")
  puts "[CHANNEL]"
  p c
  puts "[USERS]"
  p c.users
  p c.private?
  p $bot.servers
end

$bot.run(true)

while(true) do
  sleep 10
  #test
end
