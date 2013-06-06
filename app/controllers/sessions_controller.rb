class SessionsController < ApplicationController
  def create
    user = User.from_omniauth(omniauth_hash)

    if mobile_device?
      user.reset_authentication_token! if user.authentication_token.nil?
      
      redirect_to token_users_path(user_token: user.authentication_token, provider: params[:provider])
    else
      sign_in(:user, user)
      redirect_to root_path
    end
  end

  def failure
    render json: params.to_json
  end

  def omniauth_hash
    request.env['omniauth.auth']
  end
end
