class Post < ActiveRecord::Base
  attr_accessible :author, :description, :feed_id, :guid, :link, :original_link, :published_at, :title

  belongs_to :feed

  scope :read, where(read: true)
  scope :unread, where(read: false)
end
