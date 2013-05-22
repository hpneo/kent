class SessionsController < ApplicationController
  def create
    user = User.from_omniauth(omniauth_hash)
    sign_in(:user, user)

    redirect_to root_path
  end

  def failure
    render :json => params.to_json
  end

  def omniauth_hash
    request.env['omniauth.auth']
  end
end
