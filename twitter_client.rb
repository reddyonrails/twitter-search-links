# USAGE:
# ruby twitter_client.rb keyword limit
# Example: ruby twitter_client.rb news 100


require 'net/http'
require 'cgi'
require 'uri'
require 'json'

class TwitterSearch

  REGEX = /((https?:\/\/|www\.)([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/

  def initialize( key_word, tweets_limit = 100 )
    @key_word = CGI::escape( key_word )
    @tweets_limit = tweets_limit
    @tweets = []
    @hrefs = {}
  end

  def search_uri
    "http://search.twitter.com/search.json?rpp=#{@tweets_limit}&q=%23#{@key_word}"
  end

  def search
    uri = URI.parse( search_uri )
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)
    hash = JSON.parse response.body
    hash["results"].each do |tweet|
        @tweets << tweet
    end
  end

  def unique_links
    @tweets.each do |tweet|
      if href = tweet["text"].match(REGEX)
        @hrefs[ href.to_s] = true  if href
      end
    end
    @hrefs
  end
end

def main
  raise ArgumentError, "You need search keyword argument to get this work!"    unless ARGV[0]

  ts = TwitterSearch.new(ARGV[0],ARGV[1])
  ts.search
  hrefs = ts.unique_links.dup
  hrefs.each do |href,value|
    puts "#{href}"
  end
  puts "Sorry... No links available ! Please try again." if hrefs.length == 0
end

main