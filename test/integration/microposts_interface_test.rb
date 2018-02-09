require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  include ActionView::Helpers::TextHelper

  def setup
    @user = users(:michael)
  end

  test 'creation, deletion of microposts' do
    log_in_as(@user)
    get root_path
    assert_select 'h3', 'Micropost Feed'
    assert_select 'div.pagination'
    assert_select 'input[type=file]'
    # Invalid submission
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: ''} }
    end
    assert_select 'div#error_explanation'
    # Valid submission
    content = 'This is a test'
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content, picture: picture } }
    end
    micropost = assigns(:micropost)
    micropost.picture?
    # assert micropost.picture?
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # Delete micropost
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # visit different user
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count:0
  end

  test 'micropost sidebar count' do
    @user = users(:archer)
    log_in_as(@user)
    get root_path
    assert_match "2 microposts", pluralize(@user.microposts.count, 'micropost')
    post microposts_path, params: { micropost: { content: 'This is a test '}}
    get root_path
    assert_match "3 microposts", pluralize(@user.microposts.count, 'micropost')
    2.times { delete micropost_path(@user.microposts.last) }
    get root_path
    assert_match "1 micropost", pluralize(@user.microposts.count, 'micropost')
  end

end
