require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest


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

  test 'valid signup' do
    assert_difference 'User.count', 1 do
      get signup_path
      post signup_path, params: { user: {
                                          name: 'Mia',
                                          email: 'mia@test.com',
                                          password: 'testing',
                                          password_confirmation: 'testing'
        }}
    end
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
  end
end
