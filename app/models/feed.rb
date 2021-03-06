require "rexml/document"
require "net/http"
require "uri"

class Feed < ActiveRecord::Base
  attr_accessible :user_id, :title, :description, :url, :home_url, :format

  belongs_to :user
  has_many :posts, order: 'published_at DESC, id DESC'

  after_create :import_posts

  def import_posts
    existing_guids = self.posts.pluck(:guid)

    imported_posts = []

    xml_items_to_hash.each do |item|
      unless existing_guids.include?(item[:guid])
        post_hash = {
          title: item[:title],
          link: item[:link],
          guid: item[:guid],
          original_link: item[:origLink],
          author: item[:creator] || item[:author],
          description: item[:encoded] || item[:description]
        }

        if item[:pubDate]
          post_hash[:published_at] = DateTime.parse(item[:pubDate])
        end

        imported_posts << self.posts.create(post_hash)
      end
    end

    imported_posts
  end

  def posts_counter
    self.posts.unread.count
  end

  def to_param
    "#{self.id}-#{self.title.parameterize}"
  end

  def as_json(options = {})
    options ||= {}
    
    options[:methods]||= []
    options[:methods] << :posts_counter
    
    options[:except]||= []
    options[:except] += [:created_at, :updated_at, :description, :format]
    super(options)
  end

  private
  def fetch(uri_str, limit = 10)
    raise ArgumentError, 'too many HTTP redirects' if limit == 0

    begin
      response = Net::HTTP.get_response(URI.parse(uri_str))

      case response
      when Net::HTTPSuccess then
        response
      when Net::HTTPRedirection then
        location = response['location']
        fetch(location, limit - 1)
      when Net::HTTPNotFound then
        nil
      else
        response.value
      end
    rescue Exception => e
      nil
    end
  end

  def xml_items_to_hash
    items_as_array = []

    if feed_content = fetch(self.url)
      begin
        feed = REXML::Document.new(feed_content.body)

        channel = feed.root.elements.to_a('//channel').first

        items = channel.elements.to_a('//item')

        items.each do |item|
          item_as_hash = {}

          item.elements.each do |item_element|
            item_as_hash[item_element.name.to_sym] = item_element.text
          end

          items_as_array << item_as_hash
        end
      rescue Exception => e
      end
    end

    items_as_array
  end
end
