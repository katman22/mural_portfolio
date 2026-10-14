require "test_helper"

class Admin::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(username: "artist", password: "a-long-test-password")
    Admin::SessionsController::LOGIN_ATTEMPTS.clear
  end

  test "splash renders artwork branding and accessible login fields" do
    get admin_login_path
    assert_response :success
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_select "title", "Sign in · Whare Pūmanawa"
    assert_select ".entry-artwork img[alt='']", count: 1
    source = css_select(".entry-image").first["src"]
    assert_match(/admin_splash/, source)
    assert_select "label[for='username']", "Username"
    assert_select "label[for='password']", "Password"
    assert_select "input[name='username'][autocomplete='username']"
    assert_select "input[name='password'][type='password'][autocomplete='current-password']"
    assert_select "input[type='submit'][value='Sign in']"
    assert_select "script", count: 0
    assert_select "input[name='password'][value]", count: 0
  end

  test "unknown wrong and inactive credentials receive identical errors" do
    attempts = [ [ "missing", "a-long-test-password" ], [ "artist", "incorrect-password" ] ]
    attempts.each do |username, password|
      post admin_login_path, params: { username: username, password: password }
      assert_response :unprocessable_entity
      assert_select "[role='alert']", "Unable to sign in. Check your credentials and try again."
      assert_select "input[name='password'][value]", count: 0
      assert_nil request.session[:user_id]
    end
    @user.update!(active: false)
    post admin_login_path, params: { username: "artist", password: "a-long-test-password" }
    assert_response :unprocessable_entity
    assert_select "[role='alert']", "Unable to sign in. Check your credentials and try again."
    get admin_root_path
    assert_redirected_to admin_login_path
  end

  test "login throttles excessive attempts" do
    10.times { post admin_login_path, params: { username: "artist", password: "wrong" } }
    post admin_login_path, params: { username: "artist", password: "wrong" }
    assert_response :too_many_requests
    assert_select "[role='alert']", "Too many attempts. Please try again shortly."
    assert_nil request.session[:user_id]
  end

  test "csrf is required and successful login rotates the session" do
    original = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    get admin_login_path
    token = css_select("input[name='authenticity_token']").first["value"]
    old_session_id = request.session.id.to_s
    post admin_login_path, params: { username: "artist", password: "a-long-test-password" }
    assert_response :unprocessable_entity
    post admin_login_path, params: { username: "artist", password: "a-long-test-password", authenticity_token: token }
    assert_redirected_to admin_root_path
    assert_not_equal old_session_id, request.session.id.to_s
    get admin_root_path
    assert_response :success
    delete admin_logout_path
    assert_response :unprocessable_entity
    get admin_root_path
    assert_response :success
  ensure
    ActionController::Base.allow_forgery_protection = original
  end
end
