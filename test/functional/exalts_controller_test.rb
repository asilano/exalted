require 'test_helper'

class ExaltsControllerTest < ActionController::TestCase
  setup do
    @exalt = exalts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:exalts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create exalt" do
    assert_difference('Exalt.count') do
      post :create, exalt: @exalt.attributes
    end

    assert_redirected_to exalt_path(assigns(:exalt))
  end

  test "should show exalt" do
    get :show, id: @exalt.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @exalt.to_param
    assert_response :success
  end

  test "should update exalt" do
    put :update, id: @exalt.to_param, exalt: @exalt.attributes
    assert_redirected_to exalt_path(assigns(:exalt))
  end

  test "should destroy exalt" do
    assert_difference('Exalt.count', -1) do
      delete :destroy, id: @exalt.to_param
    end

    assert_redirected_to exalts_path
  end
end
