require "application_system_test_case"

class Admin::VenuesTest < ApplicationSystemTestCase
  setup do
    @venue = venues(:one)
  end

  test "visiting the index" do
    visit admin_venues_url
    assert_selector "h1", text: "Venues"
  end

  test "should create venue" do
    visit admin_venues_url
    click_on "New venue"

    fill_in "Address1", with: @venue.address1
    fill_in "Address2", with: @venue.address2
    fill_in "City", with: @venue.city
    fill_in "Map url", with: @venue.map_url
    fill_in "Name", with: @venue.name
    fill_in "Notes", with: @venue.notes
    fill_in "Postal code", with: @venue.postal_code
    fill_in "State", with: @venue.state
    click_on "Create Venue"

    assert_text "Venue was successfully created"
    click_on "Back"
  end

  test "should update Venue" do
    visit admin_venue_url(@venue)
    click_on "Edit this venue", match: :first

    fill_in "Address1", with: @venue.address1
    fill_in "Address2", with: @venue.address2
    fill_in "City", with: @venue.city
    fill_in "Map url", with: @venue.map_url
    fill_in "Name", with: @venue.name
    fill_in "Notes", with: @venue.notes
    fill_in "Postal code", with: @venue.postal_code
    fill_in "State", with: @venue.state
    click_on "Update Venue"

    assert_text "Venue was successfully updated"
    click_on "Back"
  end

  test "should destroy Venue" do
    visit admin_venue_url(@venue)
    click_on "Destroy this venue", match: :first

    assert_text "Venue was successfully destroyed"
  end
end
