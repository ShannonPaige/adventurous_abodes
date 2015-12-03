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

  test "authenticated user cannot access owner dashboard and create/update/delete trips" do
    create_and_login_user

    refute page.has_content?("Owner Dashboard")
    refute page.has_content?("Create Rentals")
    refute page.has_content?("Edit Rentals")
    refute page.has_content?("Delete Rentals")
  end
end
