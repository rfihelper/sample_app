require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    # create user fixture from /fixtures/users.yml
    @user = users(:michael)
  end

  test 'login with invalid information' do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: '', password: ''}}
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test 'login with valid information followed by logout' do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: @user.email, password: 'password' }}
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert flash.empty?
    assert_select "a[href=?]", login_path, count: 0   # does not display a login link
    assert_select "a[href=?]", logout_path        # displays logout link
    assert_select "a[href=?]", user_path(@user)   # displays profile link
    delete logout_path      # logout
    assert_not is_logged_in?
    assert_redirected_to root_url
    delete logout_path        # simulate logging out in a second browser window
    follow_redirect!
    assert_select "a[href=?]", login_path                   # does display a login link
    assert_select "a[href=?]", logout_path, count: 0        # does not display logout link
    assert_select "a[href=?]", user_path(@user), count: 0   # does not display profile link
  end

  test 'login with remembering' do
    log_in_as(@user, remember_me: '1')
    assert_not_empty cookies['remember_token']
  end

  test 'login without remembering' do
    # log in to set the cookies
    log_in_as(@user, remember_me: '1')
    # log in again and verify that the cookie is deleted
    log_in_as(@user, remember_me: '0')
    assert_empty cookies['remember_token']
  end
end
