require 'test_helper'

class BuyControllerTest < ActionDispatch::IntegrationTest
  test "should get buyrequest" do
    get buy_buyrequest_url
    assert_response :success
  end

end
