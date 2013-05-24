class PostsController < InheritedResources::Base
  before_filter :authenticate_user!

  respond_to :json, :xml, :html, :js
  def mark_as_read
    @post = Post.find(params[:id])

    @post.mark_as_read
  end

  def mark_as_unread
    @post = Post.find(params[:id])

    @post.mark_as_unread
  end
end
