require "application_system_test_case"

class Admin::EventsTest < ApplicationSystemTestCase
  setup do
    @admin_event = admin_events(:one)
  end

  test "visiting the index" do
    visit admin_events_url
    assert_selector "h1", text: "Events"
  end

  test "should create event" do
    visit admin_events_url
    click_on "New event"

    check "All day" if @admin_event.all_day
    fill_in "Category", with: @admin_event.category_id
    fill_in "Description", with: @admin_event.description
    fill_in "End at", with: @admin_event.end_at
    fill_in "External url", with: @admin_event.external_url
    fill_in "Location override", with: @admin_event.location_override
    fill_in "Source", with: @admin_event.source
    fill_in "Start at", with: @admin_event.start_at
    fill_in "Status", with: @admin_event.status
    fill_in "Title", with: @admin_event.title
    fill_in "Venue", with: @admin_event.venue_id
    click_on "Create Event"

    assert_text "Event was successfully created"
    click_on "Back"
  end

  test "should update Event" do
    visit admin_event_url(@admin_event)
    click_on "Edit this event", match: :first

    check "All day" if @admin_event.all_day
    fill_in "Category", with: @admin_event.category_id
    fill_in "Description", with: @admin_event.description
    fill_in "End at", with: @admin_event.end_at.to_s
    fill_in "External url", with: @admin_event.external_url
    fill_in "Location override", with: @admin_event.location_override
    fill_in "Source", with: @admin_event.source
    fill_in "Start at", with: @admin_event.start_at.to_s
    fill_in "Status", with: @admin_event.status
    fill_in "Title", with: @admin_event.title
    fill_in "Venue", with: @admin_event.venue_id
    click_on "Update Event"

    assert_text "Event was successfully updated"
    click_on "Back"
  end

  test "should destroy Event" do
    visit admin_event_url(@admin_event)
    click_on "Destroy this event", match: :first

    assert_text "Event was successfully destroyed"
  end
end
