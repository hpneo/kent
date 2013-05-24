require "rexml/document"

class FeedsController < InheritedResources::Base
  before_filter :authenticate_user!
  before_filter :check_ownership!

  respond_to :json, :xml, :html, :js

  def mark_all_as_read
    @posts = Post.where(feed_id: params[:id]).unread

    @posts.each(&:mark_as_read)
  end

  def import
  end

  def import_posts
    @feed = Feed.find(params[:id])
    @imported_posts = @feed.import_posts
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
    feed = Feed.find(params[:id])
    redirect_to root_path if feed.user_id != current_user.id
  end
end
