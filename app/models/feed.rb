require "rexml/document"
require "net/http"
require "uri"

class Feed < ActiveRecord::Base
  attr_accessible :user_id, :title, :description, :url, :home_url, :format

  belongs_to :user
  has_many :posts

  after_create :import_posts

  def import_posts
    feed_content = fetch(self.url).body
    feed = REXML::Document.new(feed_content)

    channel = feed.root.elements.to_a('//channel').first

    items = channel.elements.to_a('//item')

    items_as_array = []

    items.each do |item|
      item_as_hash = {}

      item.elements.each do |item_element|
        item_as_hash[item_element.name.to_sym] = item_element.text
      end

      items_as_array << item_as_hash
    end

    existing_guids = self.posts.pluck(:guid)

    items_as_array.each do |item|
      unless existing_guids.include?(item[:guid])
        self.posts.create({
          title: item[:title],
          link: item[:link],
          guid: item[:guid],
          original_link: item[:origLink],
          published_at: DateTime.parse(item[:pubDate]),
          author: item[:creator],
          description: item[:encoded] || item[:description]
        })
      end
    end
  end

  private
  def fetch(uri_str, limit = 10)
    raise ArgumentError, 'too many HTTP redirects' if limit == 0

    response = Net::HTTP.get_response(URI.parse(uri_str))

    case response
    when Net::HTTPSuccess then
      response
    when Net::HTTPRedirection then
      location = response['location']
      fetch(location, limit - 1)
    else
      response.value
    end
  end
end
