class SessionsController < ApplicationController
  def create
    user = User.from_omniauth(omniauth_hash)
    sign_in(:user, user)

    if mobile_device?
      render json: user.to_json
    else
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
