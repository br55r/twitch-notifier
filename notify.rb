require 'httparty'
require 'json'

def get_oauth_token(client_id, client_secret)
  response = HTTParty.post("https://id.twitch.tv/oauth2/token",
                           query: {
                             client_id: client_id,
                             client_secret: client_secret,
                             grant_type: 'client_credentials'
                           }
  )
  data = JSON.parse(response.body)
  return data["access_token"]
end

def check_streamer_status(oauth_token, streamer_names, client_id)
  headers = {
    "Client-ID" => client_id,
    "Authorization" => "Bearer #{oauth_token}"
  }
  streamer_query = streamer_names.map { |name| "user_login=#{name}" }.join('&')
  response = HTTParty.get("https://api.twitch.tv/helix/streams?#{streamer_query}", headers: headers)
  data = JSON.parse(response.body)

  live_streamers = []
  if data['data'].length > 0
    data['data'].each do |stream|
      live_streamers << stream['user_name'] if stream['type'] == 'live'
    end
  end

  live_streamers
end

def send_notification(title, message)
  system("notify-send '#{title}' '#{message}'")
  system("paplay alert.sound.wav") # Make sure the file is in the same directory as the script, paplay is the built in command.
end

client_id = "" # paste the client id
client_secret = "" # paste the client secret
streamer_names = [""] # paste the streamer names

oauth_token = get_oauth_token(client_id, client_secret)

loop do
  puts "Checking the status of streamers: #{streamer_names.join(', ')}..."

  live_streamers = check_streamer_status(oauth_token, streamer_names, client_id)

  if live_streamers.any?
    live_streamers.each do |streamer|
      send_notification("Streamer Alert", "#{streamer} is now live!")
    end
    puts "Notification sent. Streamers live: #{live_streamers.join(', ')}"
    break
  else
    puts "No streamers are live. Checking again in 60 seconds."
  end

  sleep(60) # Check every minute
end