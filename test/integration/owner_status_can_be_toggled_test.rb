require 'test_helper'

class OwnerStatusCanBeToggledTest < ActionDispatch::IntegrationTest
  test "An owner is removed from the owners index when their status is inactive" do
    create_user
    platform_admin = create_platform_admin
    login_platform_admin
    owner = create_active_owners(1)
    owner_id = owner.id

    assert_equal "active", owner.owner_status

    visit owners_path

    assert page.has_content?(owner.name)

    visit 'admin/dashboard'
    click_link("Manage Owners")
    click_link("make-inactive")

    assert_equal "inactive", User.find(owner_id).owner_status

    visit owners_path

    refute page.has_content?(owner.name)
  end
end
