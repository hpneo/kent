class PostsController < InheritedResources::Base
  before_filter :authenticate_user!

  respond_to :json, :xml, :html, :js
end
