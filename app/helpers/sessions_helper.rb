module SessionsHelper

  # logs in given user
  def log_in(user)
    session[:user_id] = user.id
  end

  # returns (and logs in) the user corresponding to the remember token cookie
  def current_user
    if (user_id = session[:user_id])    # set user_id to session user id if it exists
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])    # set user_id to cookie user id if it exists
      user = User.find_by(id:user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # returns true if the given user is the current user
  def current_user?(user)
    user == current_user
  end

  # returns boolean if user logged in
  def logged_in?
    !current_user.nil?
  end

  # log out user
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # remembers a user in a persistent session (cookie)
  def remember(user)
    user.remember     # creates the token and stores the hash in the user record
    cookies.permanent.signed[:user_id] = user.id              # hashed (signed) user id
    cookies.permanent[:remember_token] = user.remember_token  # actual (unhashed) token
  end

  def forget(user)
    user.forget     # resets the users remember_digest to nil
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # redirects to stored location (or to the default)
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # stores the URL trying to be accessed
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end


end
