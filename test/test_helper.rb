ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require "rails/test_help"
require "capybara/rails"
require "mocha/mini_test"
require "minitest/pride"
require "simplecov"

SimpleCov.start "rails"

class ActiveSupport::TestCase
end

class ActionDispatch::IntegrationTest
  include Capybara::DSL

  def create_user
    User.create!(username: "cole", name: "Nicole", password: "password")
  end

  def create_owner
    User.create!(username: "owner", name: "owner", password: "password", role: 1)
  end

  def create_and_login_user
    @user = create_user

    visit login_path
    fill_in "Username", with: @user.username
    fill_in "Password", with: "password"
    click_button "Login"
  end

  def create_rentals(num, rental_type)
    num.times do |i|
      i += 1
      rental_type = RentalType.find_or_create_by(name: rental_type)
      rental_type.rentals.create(name: "Castle #{i}",
                               description: "No dragons allowed. #{i}",
                               price: 1000 + i)
    end
  end

  def create_rentals_for_owner(num, rental_type)
    owner = create_owner

    num.times do |i|
      i += 1
      rental_type = RentalType.find_or_create_by(name: rental_type)
      rental_type.rentals.create(name: "Castle #{i}",
                               description: "No dragons allowed. #{i}",
                               price: 1000 + i)
      owner.rentals << Rental.last(i)
    end

  end

  def create_orders
    create_and_login_user

    rental_type = RentalType.create(name: "Castle")
    rental_type_id = rental_type.id
    order1 = @user.orders.create(total: 1001,
                                created_at: Time.new(2011, 11, 10, 15, 25, 0))
    order2 = @user.orders.create(total: 200,
                                created_at: Time.new(2012, 11, 12, 15, 25, 0))

    order1.rentals.create(name: "Castle",
                          description: "No Dragons Allowed.",
                          price: 1001,
                          rental_type_id: rental_type_id)

    order2.rentals.create(name: "Treehouse",
                          description: "Perfect for Swiss families.",
                          price: 200,
                          rental_type_id: rental_type_id)
  end

  def add_items_to_cart(num)
    num.times do |i|
      i += 1
      create_rentals(1, "Castle #{i}")
      rental = RentalType.find_by_name("Castle #{i}").rentals.first

      visit rental_path(rental)
      click_link "Purchase Trip"
      click_button "Place Order"
    end
  end

  def checkout_user(num_items)
    create_and_login_user
    add_items_to_cart(num_items)
    visit "/cart"
    click_button "Checkout"
  end

  def teardown
    reset_session!
  end

  def login_owner
    User.create(username: "owner", name: "Owner", password: "password", role: 1)
    visit login_path
    fill_in "Username", with: "owner"
    fill_in "Password", with: "password"
    click_button "Login"
  end
end
