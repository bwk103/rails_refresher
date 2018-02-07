require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test 'invalid edits' do
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
end
