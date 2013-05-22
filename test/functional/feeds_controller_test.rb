require 'test_helper'

class FeedsControllerTest < ActionController::TestCase
  test "should get import" do
    get :import
    assert_response :success
  end

end
