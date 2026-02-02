require "test_helper"

class Admin::VenuesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_venue = admin_venues(:one)
  end

  test "should get index" do
    get admin_venues_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_venue_url
    assert_response :success
  end

  test "should create admin_venue" do
    assert_difference("Admin::Venue.count") do
      post admin_venues_url, params: { admin_venue: { address1: @admin_venue.address1, address2: @admin_venue.address2, city: @admin_venue.city, map_url: @admin_venue.map_url, name: @admin_venue.name, notes: @admin_venue.notes, postal_code: @admin_venue.postal_code, state: @admin_venue.state } }
    end

    assert_redirected_to admin_venue_url(Admin::Venue.last)
  end

  test "should show admin_venue" do
    get admin_venue_url(@admin_venue)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_venue_url(@admin_venue)
    assert_response :success
  end

  test "should update admin_venue" do
    patch admin_venue_url(@admin_venue), params: { admin_venue: { address1: @admin_venue.address1, address2: @admin_venue.address2, city: @admin_venue.city, map_url: @admin_venue.map_url, name: @admin_venue.name, notes: @admin_venue.notes, postal_code: @admin_venue.postal_code, state: @admin_venue.state } }
    assert_redirected_to admin_venue_url(@admin_venue)
  end

  test "should destroy admin_venue" do
    assert_difference("Admin::Venue.count", -1) do
      delete admin_venue_url(@admin_venue)
    end

    assert_redirected_to admin_venues_url
  end
end
