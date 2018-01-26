require 'test_helper'

class PostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "post interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    # Invalid submission
    assert_no_difference 'Post.count' do
      post posts_path, params: { post: { content: "" } }
    end
    assert_select 'div#error_explanation'
    # Valid submission
    content = "This post really ties the room together"
    assert_difference 'Post.count', 1 do
      post posts_path, params: { post: { content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # Delete posts
    assert_select 'a', test: 'delete'
    first_post = @user.posts.paginate(page: 1).first
    assert_difference 'Post.count', -1 do
      delete post_path(first_post)
    end
    # Visit different user (no delete links)
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end

  test "post sidebar count" do
    log_in_as(@user)
    get root_path
    assert_match "#{@user.posts.count} posts", response.body
    #User with no posts
    other_user = users(:malory)
    log_in_as(other_user)
    get root_path
    assert_match "0 posts", response.body
    other_user.posts.create!(content: "A post!")
    get root_path
    assert_match "1 post", response.body
  end

end
