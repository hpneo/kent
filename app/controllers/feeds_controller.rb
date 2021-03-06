require "rexml/document"

class FeedsController < InheritedResources::Base
  before_filter :authenticate_user!
  before_filter :check_ownership!, :only => [:edit, :show, :update, :destroy, :posts, :mark_all_as_read, :import_posts]

  respond_to :json, :xml, :html, :js

  def index
    @feeds = current_user.feeds
    index!
  end

  def posts
    @posts = @feed.posts
    @posts = @posts.unread if params[:only_unread] == "true"

    render json: @posts
  end

  def mark_all_as_read
    @feed_id = params[:id].to_i
    @posts = Post.where(feed_id: params[:id]).unread

    @posts.each(&:mark_as_read)
    @unread_posts_counter = Post.unread.where(feed_id: @feed_id).count
  end

  def import
  end

  def refresh
    @feed_post_counters = {}
    current_user.feeds.each do |feed|
      @feed_post_counters[feed.id] = Post.unread.where(feed_id: feed.id).count
    end
  end

  def import_all_posts
    @feeds = current_user.feeds.each(&:import_posts)

    render json: @feeds
  end

  def import_posts
    @imported_posts = @feed.import_posts
    @unread_posts_counter = Post.unread.where(feed_id: @feed.id).count

    respond_to do |format|
      format.js
      format.html
      format.json {
        render json: [@feed]
      }
    end
  end

  def import_subscriptions
    subscriptions_file = params[:import][:subscriptions]

    opml = REXML::Document.new(subscriptions_file.read)

    subscriptions = opml.root.elements.to_a('//outline').map(&:attributes)

    current_user.import_feeds(subscriptions)

    render json: current_user.feeds
  end

  def destroy
    destroy! { root_path }
  end

  def check_ownership!
    @feed = Feed.find(params[:id])
    redirect_to root_path if @feed.user_id != current_user.id
  end
end
