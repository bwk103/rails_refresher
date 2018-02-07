require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test 'invalid edits' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: {
                                              name: '',
                                              email: 'user.email',
                                              password: 'password',
                                              password_confirmation: 'password'
      }}
    assert_template 'users/edit'
    assert_select 'div.alert', 'The form contains 2 errors.'
  end

  test 'valid edits' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: {
                                              name: 'Mike Example',
                                              email: @user.email,
                                              password: 'password',
                                              password_confirmation: 'password'
      }}
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal @user.name, 'Mike Example'
  end

  test 'valid edit with friendly forwarding' do
    get edit_user_path(@user)
    assert_redirected_to login_path
    assert_equal session[:forwarding_url], edit_user_url(@user)
    post login_path, params: { session: {
                                          email: @user.email,
                                          password: 'password'
      }}
    assert_redirected_to edit_user_path(@user)
  end

  test 'friendly forwarding only stores location once' do
    get edit_user_path(@user)
    assert_redirected_to login_path
    assert_equal session[:forwarding_url], edit_user_url(@user)
    post login_path, params: { session: {
                                          email: @user.email,
                                          password: 'password'
      }}
    delete logout_path
    assert_not is_logged_in?
    get login_path
    post login_path, params: { session: {
                                          email: @user.email,
                                          password: 'password'
      }}
    assert_redirected_to @user
    assert_nil session[:forwarding_url]
  end
end
