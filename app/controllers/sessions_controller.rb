class SessionsController < ApplicationController

  # log in page
  def new
  end

  # log in action
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password]) then
      # log in
      log_in(user)
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email / password combination'
      render 'new'
    end
  end

  # log out action
  def destroy
    log_out
    redirect_to root_url
  end
end
