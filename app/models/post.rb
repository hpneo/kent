class Post < ActiveRecord::Base
  attr_accessible :author, :description, :feed_id, :guid, :link, :original_link, :published_at, :read, :title

  belongs_to :feed

  scope :read, where(read: true)
  scope :unread, where(read: false)

  def mark_as_read
    self.read = true
    self.save
  end

  def mark_as_unread
    self.read = false
    self.save
  end

  def published_at_timestamp
    self.published_at.utc.to_i
  end

  def as_json(options = {})
    options ||= {}
    
    options[:methods]||= []
    options[:methods] << :published_at_timestamp
    
    options[:except]||= []
    options[:except] += [:created_at, :updated_at]
    super(options)
  end
end
