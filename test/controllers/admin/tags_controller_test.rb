require "test_helper"

class Admin::TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tag = tags(:one)
  end

  test "should get index" do
    get admin_tags_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_tag_url
    assert_response :success
  end

  test "should create tag" do
    assert_difference("Tag.count") do
      post admin_tags_url, params: { tag: { is_active: @tag.is_active, name: @tag.name, slug: @tag.slug } }
    end

    assert_redirected_to admin_tag_url(Tag.last)
  end

  test "should show tag" do
    get admin_tag_url(@tag)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_tag_url(@tag)
    assert_response :success
  end

  test "should update tag" do
    patch admin_tag_url(@tag), params: { tag: { is_active: @tag.is_active, name: @tag.name, slug: @tag.slug } }
    assert_redirected_to admin_tag_url(@tag)
  end

  test "should destroy tag" do
    assert_difference("Tag.count", -1) do
      delete admin_tag_url(@tag)
    end

    assert_redirected_to admin_tags_url
  end
end
