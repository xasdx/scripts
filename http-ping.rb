# An object that executes a GET on a collection of URLs.
# Intended to wake up multiple sleeping dynos on heroku.
# https://devcenter.heroku.com/articles/free-dyno-hours#dyno-sleeping

require "typhoeus"

class HttpPing
  
  def initialize(urls)
    @urls = urls
    @hydra = Typhoeus::Hydra.new
  end
  
  def ping
    @urls.each do |url|
      puts "GET - #{url}"
      res = Typhoeus.get(url)
      puts "#{res.code} - #{url}"
    end
  end
  
  def ping_parallel
    @urls.each do |url|
      puts "GET - #{url}"
      req = Typhoeus::Request.new(url)
      req.on_complete do |res|
        puts "#{res.code} - #{url}"
      end
      @hydra.queue(req)
    end
    @hydra.run
  end
end

if __FILE__==$0
  HttpPing.new([
    "http://www.google.com",
    "https://www.twitch.tv",
    "https://www.youtube.com"
  ]).ping_parallel
end
