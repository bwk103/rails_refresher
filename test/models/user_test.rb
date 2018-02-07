require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: 'Ben', email: 'ben@test.com', password:'testing',
                     password_confirmation:'testing')
  end

  test 'it creates a valid user' do
    assert @user.valid?
  end

  test 'it does not allow for empty names' do
    @user.name = ''
    assert_not @user.valid?
  end

  test 'it does not allow email to be empty' do
    @user.email = ''
    assert_not @user.valid?
  end

  test 'usernames should not be more than 50 characters long' do
    @user.name = 'This is just a long string and really shouldnt be allowed to be a name at all'
    assert_not @user.valid?
  end

  test 'email validation should allow valid addresses' do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test 'email validation should reject invalid addresses' do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test 'emails should be unique' do
    @user.save
    @user2 = User.new(name:'Bob',email: 'BEN@TEST.com', password: 'test',
                      password_confirmation: 'test')
    assert_not @user2.valid?
  end

  test 'duplicate emails in different cases should not be valid' do
    @user.save
    @user2 = @user.dup
    assert_not @user2.valid?
  end

  test 'emails are saved as lower case strings' do
    mixed_case_email = "BoB@tEsT.cOm"
    @user.email = mixed_case_email
    @user.save
    assert_equal 'bob@test.com', @user.reload.email
  end

  test 'passwords should not be blank' do
    @user.password = " " * 6
    @user.password_confirmation = " " * 6
    @user.save
    assert_not @user.valid?
  end

  test 'passwords should have min length' do
    @user.password = 'abc'
    @user.password_confirmation = 'abc'
    @user.save
    assert_not @user.valid?
  end

  test 'authenticated? should return false for use with nil digest' do
    assert_not @user.authenticated?('')
  end

end
