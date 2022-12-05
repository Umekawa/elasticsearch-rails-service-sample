require 'net/http'
require 'json'

uri = URI.parse ('https://qiita.com/api/v2/items')
11.times do |month|
  90.times do |page|
    uri.query = URI.encode_www_form({ query: "created:2022-#{month+1}", per_page: 100, page: page+1, sort: 'created' })
    req = Net::HTTP::Get.new(uri.request_uri)
    req['Authorization'] = "Bearer #{ENV['ACCESS_TOKEN']}"

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    res = http.request(req)

    total_page = ((res['total-count'].to_i - 1) / 100) + 1
    total_page = total_page > 100 ? 100 : total_page

    puts "API Limit:#{res['rate-remaining']}/#{res['rate-limit']}, reset:#{Time.zone.at(res['rate-reset'].to_i)}"

    sleep 2
    puts JSON.parse(res.body)
    File.open("data/#{month+1}-#{page+1}.json", mode = "w"){|f|
      f.write(res.body) 
    }
    break if page > total_page
  end
end
