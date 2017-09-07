require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get vacation" do
    get :vacation
    assert_response :success
  end

  test "should get residential" do
    get :residential
    assert_response :success
  end

  test "should get commercial" do
    get :commercial
    assert_response :success
  end

end
