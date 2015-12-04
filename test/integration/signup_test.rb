require "test_helper"

class SignupTest < ActionDispatch::IntegrationTest
  test "guest can create an account" do
    create_roles
    visit root_path
    click_on "Login"
    assert_equal login_path, current_path
    click_link "Join"
    assert_equal new_user_path, current_path
    fill_in "Username", with: "Nicole@gmail.com"
    fill_in "Name", with: "Nicole"
    fill_in "Password", with: "password"
    click_button "Create Account"

    assert_equal "/dashboard", current_path
    assert page.has_content?("Welcome, Nicole!")
    assert page.has_content?("Username: Nicole@gmail.com")
    assert page.has_content?("Name: Nicole")
  end

  test "guest must signup with username" do
    create_roles
    visit root_path
    click_on "Login"
    assert_equal login_path, current_path
    click_on "Join"
    assert_equal new_user_path, current_path
    fill_in "Username", with: ""

    fill_in "Name", with: "Nicole"
    fill_in "Password", with: "password"
    click_button "Create Account"

    assert_equal login_path, current_path
    assert page.has_content?("Invalid user credentials. Please try again.")
  end

  test "user cannot create an account if already logged in" do
    create_and_login_user
    visit new_user_path

    refute page.has_content?("Create Account")
    assert page.has_content?("You are already logged in as Nicole.")
  end
end
