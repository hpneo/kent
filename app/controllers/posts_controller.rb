class PostsController < InheritedResources::Base
  before_filter :authenticate_user!
  before_filter :check_ownership!, :only => [:mark_as_read, :mark_as_unread]

  respond_to :json, :xml, :html, :js

  def mark_as_read
    @post = Post.find(params[:id])
    @post.mark_as_read

    @unread_posts_counter = Post.unread.where(feed_id: @post.feed_id).count
  end

  def mark_as_unread
    @post = Post.find(params[:id])
    @post.mark_as_unread
    
    @unread_posts_counter = Post.unread.where(feed_id: @post.feed_id).count
  end

  def mark_all_as_read
    @posts = current_user.posts.unread

    @posts.each(&:mark_as_read)
    @unread_posts_counter = current_user.posts.unread.count
  end

  def check_ownership!
    feed = Post.find(params[:id]).feed
    redirect_to root_path if feed.user_id != current_user.id
  end
end
