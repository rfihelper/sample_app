module SessionsHelper

  # logs in given user
  def log_in(user)
    session[:user_id] = user.id
  end

  # returns current logged in user object (if any)
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # returns boolean if user logged in
  def logged_in?
    !current_user.nil?
  end

  # log out user
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

end
