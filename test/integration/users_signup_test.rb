require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end


  test 'invalid signup' do
    assert_no_difference 'User.count' do
      get signup_path
      post signup_path, params: { user: {
                                    name: '',
                                    email: 'test@test.com',
                                    password: 'testing',
                                    password_confirmation: 'testing'
        }}
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'li', "Name can't be blank"
    assert_select 'form[action="/signup"]'
  end

  test 'valid signup with account activation' do
    get signup_path
    assert_difference 'User.count', 1 do
      post signup_path, params: { user: {
                                          name: 'Mia',
                                          email: 'mia@test.com',
                                          password: 'testing',
                                          password_confirmation: 'testing'
        }}
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    log_in_as(user)
    assert_not is_logged_in?
    get edit_account_activation_path('Incorrect activation link', email: user.email)
    assert_not is_logged_in?
    get edit_account_activation_path(user.activation_token, email: 'Incorrect')
    assert_not is_logged_in?
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
