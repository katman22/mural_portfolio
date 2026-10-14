require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(username: "artist", password: "a-long-test-password")
    Admin::SessionsController::LOGIN_ATTEMPTS.clear
  end

  test "unauthenticated administration redirects to login without a Basic challenge" do
    get admin_root_path
    assert_redirected_to admin_login_path
    assert_nil response.headers["WWW-Authenticate"]
    get admin_root_path, headers: { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials("artist", "a-long-test-password") }
    assert_redirected_to admin_login_path
  end

  test "login gives access and logout clears it" do
    post admin_login_path, params: { username: " ARTIST ", password: "a-long-test-password" }
    assert_response :see_other
    assert_redirected_to admin_root_path
    assert_equal @user.id, request.session[:user_id]
    assert_nil request.session[:password]
    get admin_root_path
    assert_response :success
    assert_select "h1", "Portfolio administration"
    assert_select "form[action=?]", admin_logout_path
    delete admin_logout_path
    assert_redirected_to admin_login_path
    assert_nil request.session[:user_id]
    get admin_root_path
    assert_redirected_to admin_login_path
  end

  test "deactivated and deleted users lose existing admin access" do
    post admin_login_path, params: { username: @user.username, password: "a-long-test-password" }
    @user.update!(active: false)
    get admin_root_path
    assert_redirected_to admin_login_path
    @user.update!(active: true)
    post admin_login_path, params: { username: @user.username, password: "a-long-test-password" }
    @user.destroy!
    get admin_root_path
    assert_redirected_to admin_login_path
  end
end
