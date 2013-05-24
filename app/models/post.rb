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
end
