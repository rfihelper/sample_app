class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

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
      # send activation email before logging in; return to the root URL
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
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

  # action to show all users
  def index
    @users = User.paginate(page: params[:page])
  end

  # action to delete users
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :admin)
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

    # confirms an admin user
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
