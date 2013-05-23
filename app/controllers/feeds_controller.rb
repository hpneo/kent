require "rexml/document"

class FeedsController < InheritedResources::Base
  before_filter :authenticate_user!

  respond_to :json, :xml, :html, :js

  def import
  end

  def import_subscriptions
    subscriptions_file = params[:import][:subscriptions]

    opml = REXML::Document.new(subscriptions_file.read)

    subscriptions = opml.root.elements.to_a('//outline').map(&:attributes)

    current_user.import_feeds(subscriptions)

    render json: current_user.feeds
  end
end
