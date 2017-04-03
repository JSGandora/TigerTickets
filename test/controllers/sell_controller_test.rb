require 'test_helper'

class SellControllerTest < ActionDispatch::IntegrationTest
  test "should get sellrequest" do
    get sell_sellrequest_url
    assert_response :success
  end

end
