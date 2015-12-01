require "test_helper"

class UserCanSeePastOrdersTest < ActionDispatch::IntegrationTest
  test "user can see past orders" do
    create_and_login_user
    user = User.first

    RentalType.create(name: "General")
    rental_type_id = RentalType.first.id

    # TO DO: MOCHA GEM STUB DATE
    order1 = user.orders.create(total: 1001,
                                created_at: Time.new(2011, 11, 10, 15, 25, 0))
    order2 = user.orders.create(total: 200,
                                created_at: Time.new(2012, 11, 12, 15, 25, 0))

    order1.rentals.create(name: "Hiking",
                           description: "Hike the Alps",
                           price: 1001,
                           rental_type_id: rental_type_id)

    order2.rentals.create(name: "Jet Skiing",
                           description: "Jet Skiing in Jamaica",
                           price: 200,
                           rental_type_id: rental_type_id)

    visit orders_path

    assert page.has_content?("Order History")

    within(".cart-table") do # within() vs. within_table() ?!
      assert page.has_content?("Trips Ordered")
      assert page.has_content?("Total Price")
      assert page.has_content?("Date Ordered")

      assert page.has_content?("Hiking (Travellers: 1)")
      assert page.has_content?("$1,001")
      assert page.has_content?("November 10, 2011")

      assert page.has_content?("Jet Skiing (Travellers: 1)")
      assert page.has_content?("$200")
      assert page.has_content?("November 12, 2012")
    end
  end

  test "user can place an order and is redirected to the order history page" do
    checkout_user(2)

    assert page.has_content?("Order History")

    within(".cart-table") do
      assert page.has_content?("Trips Ordered")
      assert page.has_content?("Total Price")
      assert page.has_content?("Date Ordered")

      assert page.has_content?("Hiking the Alps 1 (Travellers: 1)")
      assert page.has_content?("Hiking the Alps 1 (Travellers: 2)")
      assert page.has_content?("$3,003")
      assert page.has_content?("#{Order.first.created_at.strftime("%B %d, %Y")}")
    end
  end

  test "authenticated user can see individual past orders" do
    checkout_user(1)
    order = Order.first
    order_timestamp = order.created_at
    formatted_timestamp = "#{order_timestamp.strftime("%B %d, %Y")} at #{order_timestamp.strftime("%H:%M")}"

    visit orders_path

    click_link "View"
    assert_equal order_path(order), current_path

    assert page.has_content?("Sub-total")
    assert page.has_content?("Name")

    assert page.has_content?("Hiking the Alps 1 (Travellers: 1)")
    assert page.has_content?("$1,001")

    assert page.has_content?("Order status: Pending")
    assert page.has_content?("Total price: $1,001")

    assert page.has_content?("Order submitted on #{formatted_timestamp}")

    assert page.has_content?("Last order status update: #{formatted_timestamp}")
    assert page.has_content?("Retired?")

    click_link("Hiking the Alps 1 (Travellers: 1)")
    assert_equal rental_path(Rental.find_by_name("Hiking the Alps 1")), current_path
  end

  test "user can access a retired rental page from their order history" do
    checkout_user(1)
    rental = Rental.first
    rental.retire

    visit order_path(Order.first)
    click_link("Hiking the Alps 1 (Travellers: 1)")

    assert_equal rental_path(rental), current_path
    refute page.has_content?("Purchase Trip")
  end

  test "user can access order history from user dashboard" do
    create_and_login_user

    click_link("Order History")
    assert_equal orders_path, current_path
  end
end
