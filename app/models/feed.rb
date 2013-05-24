require "rexml/document"
require "net/http"
require "uri"

class Feed < ActiveRecord::Base
  attr_accessible :user_id, :title, :description, :url, :home_url, :format

  belongs_to :user
  has_many :posts

  after_create :import_posts

  def import_posts
    existing_guids = self.posts.pluck(:guid)

    imported_posts = []

    xml_items_to_hash.each do |item|
      unless existing_guids.include?(item[:guid])
        imported_posts << self.posts.create({
          title: item[:title],
          link: item[:link],
          guid: item[:guid],
          original_link: item[:origLink],
          published_at: DateTime.parse(item[:pubDate]),
          author: item[:creator] || item[:author],
          description: item[:encoded] || item[:description]
        })
      end
    end

    imported_posts
  end

  def to_param
    "#{self.id}-#{self.title.parameterize}"
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

  def xml_items_to_hash
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

    items_as_array
  end
end
