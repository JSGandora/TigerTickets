require 'test_helper'

class AccountControllerTest < ActionDispatch::IntegrationTest
  test "should get mytix" do
    get account_mytix_url
    assert_response :success
  end

end
