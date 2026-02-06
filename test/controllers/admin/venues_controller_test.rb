require "test_helper"

class Admin::VenuesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @venue = venues(:one)
  end

  test "should get index" do
    get admin_venues_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_venue_url
    assert_response :success
  end

  test "should create venue" do
    assert_difference("Venue.count") do
      post admin_venues_url, params: { venue: { address1: @venue.address1, address2: @venue.address2, city: @venue.city, map_url: @venue.map_url, name: @venue.name, notes: @venue.notes, postal_code: @venue.postal_code, state: @venue.state } }
    end

    assert_redirected_to admin_venue_url(Venue.last)
  end

  test "should show venue" do
    get admin_venue_url(@venue)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_venue_url(@venue)
    assert_response :success
  end

  test "should update venue" do
    patch admin_venue_url(@venue), params: { venue: { address1: @venue.address1, address2: @venue.address2, city: @venue.city, map_url: @venue.map_url, name: @venue.name, notes: @venue.notes, postal_code: @venue.postal_code, state: @venue.state } }
    assert_redirected_to admin_venue_url(@venue)
  end

  test "should destroy venue" do
    assert_difference("Venue.count", -1) do
      delete admin_venue_url(@venue)
    end

    assert_redirected_to admin_venues_url
  end
end
