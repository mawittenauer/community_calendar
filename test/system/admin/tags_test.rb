require "application_system_test_case"

class Admin::TagsTest < ApplicationSystemTestCase
  setup do
    @admin_tag = admin_tags(:one)
  end

  test "visiting the index" do
    visit admin_tags_url
    assert_selector "h1", text: "Tags"
  end

  test "should create tag" do
    visit admin_tags_url
    click_on "New tag"

    check "Is active" if @admin_tag.is_active
    fill_in "Name", with: @admin_tag.name
    fill_in "Slug", with: @admin_tag.slug
    click_on "Create Tag"

    assert_text "Tag was successfully created"
    click_on "Back"
  end

  test "should update Tag" do
    visit admin_tag_url(@admin_tag)
    click_on "Edit this tag", match: :first

    check "Is active" if @admin_tag.is_active
    fill_in "Name", with: @admin_tag.name
    fill_in "Slug", with: @admin_tag.slug
    click_on "Update Tag"

    assert_text "Tag was successfully updated"
    click_on "Back"
  end

  test "should destroy Tag" do
    visit admin_tag_url(@admin_tag)
    click_on "Destroy this tag", match: :first

    assert_text "Tag was successfully destroyed"
  end
end
