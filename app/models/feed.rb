class Feed < ActiveRecord::Base
  attr_accessible :user_id, :title, :description, :url, :home_url, :format

  belongs_to :user
end
