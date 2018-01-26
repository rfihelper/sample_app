class PostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user, only: :destroy

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      flash[:success] = "Post created."
      redirect_to root_url
    else
      # home page expects a @feed_items for the feed partial
      # send an empty feed_items array so it won't error
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    if @post.destroy
      flash[:success] = "Post removed."
    else
      flash[:warning] = "Post not removed."
    end
    redirect_to request.referrer || root_url
  end

  private

    def post_params
      params.require(:post).permit(:content, :image)
    end

    def correct_user
      @post = current_user.posts.find_by( id: params[:id] )
      redirect_to root_url if @post.nil?
    end

end
