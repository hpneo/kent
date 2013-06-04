class ApplicationController < ActionController::Base
  protect_from_forgery

  private

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent.downcase =~ /mobile|webos|android|ios/
    end
  end

  helper_method :mobile_device?
end
