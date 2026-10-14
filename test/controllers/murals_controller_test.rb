require "test_helper"

class MuralsControllerTest < ActionDispatch::IntegrationTest
  test "root is an artist-specific server-rendered foundation" do
    get root_path
    assert_response :success
    assert_select "h1", "Mural Portfolio"
    assert_select "script[type='importmap']", count: 1
    assert_no_match(/Aura Weather/, response.body)
  end

  test "draft and missing mural slugs are not public" do
    mural = Mural.create!(title: "Unpublished")
    get mural_path(mural.slug)
    assert_response :not_found
    get mural_path("missing")
    assert_response :not_found
  end

  test "published mural lookup uses the stable slug" do
    mural = Mural.create!(title: "Blue Heron")
    photo = mural.mural_photos.create!(alt_text: "Blue heron mural")
    photo.image.attach(io: File.open(file_fixture("mural.png")), filename: "mural.png", content_type: "image/png")
    mural.update!(published: true)
    mural.update!(title: "Updated Title")
    get mural_path("blue-heron")
    assert_response :success
    assert_select "h1", "Updated Title"
  end
end
