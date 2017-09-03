class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update]
  before_action :correct_user, only: [:edit, :update]

  # display the sign up page
  def new
    @user = User.new
  end

  # display the user profile page
  def show
    @user = User.find(params[:id])
  end

  # action when the sign up page is submitted
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App"
      redirect_to @user
    else
      # invalid / does not save user. Go back to the sign up page
      # automatically display the problems in the header partial for /new
      render 'new'
    end
  end

  # display the settings page
  def edit
  end

  # action when the settings page is submitted
  def update
    if @user.update_attributes(user_params)
      # successful update
      flash[:success] = 'Profile updated'
      redirect_to @user
    else
      # unsuccessful update
      render 'edit'
    end

  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # confirms a logged in user
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = 'Please log in'
        redirect_to login_url
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
end
