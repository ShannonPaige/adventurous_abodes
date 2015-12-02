require "test_helper"

class UserCanCheckoutTest < ActionDispatch::IntegrationTest
  test "user must be logged in to checkout" do
    add_items_to_cart(1)
    visit "/cart"
    click_button "Checkout"

    assert page.has_content?("You must be logged in to checkout")
    assert_equal login_path, current_path
  end

  test "logged in user can checkout" do
    checkout_user(1)

    assert_equal "/orders", current_path
    assert page.has_content?("Order was successfully placed")

  end

  test "cart resets to empty when user checks out" do
    checkout_user(1)
    visit rentals_path

    assert page.has_content?("Trips: 0")
  end

  test "user can't checkout with no items in cart" do
    create_and_login_user
    visit "/cart"

    assert page.has_content?("No items in cart.")
    refute page.has_content?("Checkout")
  end
end
