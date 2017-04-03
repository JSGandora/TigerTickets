require 'test_helper'

class ShowsViewControllerTest < ActionDispatch::IntegrationTest
  test "should get getshows" do
    get shows_view_getshows_url
    assert_response :success
  end

end
