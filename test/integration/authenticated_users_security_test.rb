require "test_helper"

class AuthenticatedUsersSecurityTest < ActionDispatch::IntegrationTest
  test "authenticated user cannot access another users dashboard" do
    User.create(name: "Nicole", username: "cole", password: "password")
    User.create(name: "Torie", username: "torie", password: "pass")

    visit login_path

    fill_in "Username", with: "cole"
    fill_in "Password", with: "pass"
    click_button "Login"

    assert_equal "/login", current_path
  end

  test "authenticated user cannot make themself an admin" do
    visit root_path
    click_button "Apply for Membership"

    fill_in "Username", with: "cole"
    fill_in "Name", with: "Cole"
    fill_in "Password", with: "pass"

    refute page.has_content?("Role")
    click_button "Create Account"
  end

  test "authenticated user cannot access admin dashboard and create/update/delete trips" do
    create_and_login_user

    refute page.has_content?("Admin Dashboard")
    refute page.has_content?("Create Rentals")
    refute page.has_content?("Edit Rentals")
    refute page.has_content?("Delete Rentals")
  end
end
