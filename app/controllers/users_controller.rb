class UsersController < ApplicationController
  def token
    head :ok
  end

  def verify_token
    authentication_token = params[:auth_token]
    if User.find_by_authentication_token(authentication_token).nil?
      render json: {
        status: 'error'
      }
    else
      render json: {
        status: 'success'
      }
    end
  end
end