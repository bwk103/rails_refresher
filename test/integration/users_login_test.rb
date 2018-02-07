require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test 'invalid login' do
    get login_path
    post login_path, params: { session: {
                                          email: 'bob@test.com',
                                          password: 'wrong'
                                          }}
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test 'valid login' do
    get login_path
    post login_path, params: { session: {
                                          email: @user.email,
                                          password: 'password'
      }}
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", logout_path
    delete logout_path
    assert_redirected_to root_path
    assert_not is_logged_in?
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
end
