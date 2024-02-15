require "controllers/api/v1/test"

class Api::V1::MatchesControllerTest < Api::Test
def setup
  # See `test/controllers/api/test.rb` for common set up for API tests.
  super

  @match = build(:match, team: @team)
  @other_matches = create_list(:match, 3)

  @another_match = create(:match, team: @team)

  # 🚅 super scaffolding will insert file-related logic above this line.
  @match.save
  @another_match.save

  @original_hide_things = ENV["HIDE_THINGS"]
  ENV["HIDE_THINGS"] = "false"
  Rails.application.reload_routes!
end

def teardown
  super
  ENV["HIDE_THINGS"] = @original_hide_things
  Rails.application.reload_routes!
end

# This assertion is written in such a way that new attributes won't cause the tests to start failing, but removing
# data we were previously providing to users _will_ break the test suite.
def assert_proper_object_serialization(match_data)
  # Fetch the match in question and prepare to compare it's attributes.
  match = Match.find(match_data["id"])

  assert_equal_or_nil match_data['name'], match.name
  # 🚅 super scaffolding will insert new fields above this line.

  assert_equal match_data["team_id"], match.team_id
end

test "index" do
  # Fetch and ensure nothing is seriously broken.
  get "/api/v1/teams/#{@team.id}/matches", params: {access_token: access_token}
  assert_response :success

  # Make sure it's returning our resources.
  match_ids_returned = response.parsed_body.map { |match| match["id"] }
  assert_includes(match_ids_returned, @match.id)

  # But not returning other people's resources.
  assert_not_includes(match_ids_returned, @other_matches[0].id)

  # And that the object structure is correct.
  assert_proper_object_serialization response.parsed_body.first
end

test "show" do
  # Fetch and ensure nothing is seriously broken.
  get "/api/v1/matches/#{@match.id}", params: {access_token: access_token}
  assert_response :success

  # Ensure all the required data is returned properly.
  assert_proper_object_serialization response.parsed_body

  # Also ensure we can't do that same action as another user.
  get "/api/v1/matches/#{@match.id}", params: {access_token: another_access_token}
  assert_response :not_found
end

test "create" do
  # Use the serializer to generate a payload, but strip some attributes out.
  params = {access_token: access_token}
  match_data = JSON.parse(build(:match, team: nil).api_attributes.to_json)
  match_data.except!("id", "team_id", "created_at", "updated_at")
  params[:match] = match_data

  post "/api/v1/teams/#{@team.id}/matches", params: params
  assert_response :success

  # # Ensure all the required data is returned properly.
  assert_proper_object_serialization response.parsed_body

  # Also ensure we can't do that same action as another user.
  post "/api/v1/teams/#{@team.id}/matches",
    params: params.merge({access_token: another_access_token})
  assert_response :not_found
end

test "update" do
  # Post an attribute update ensure nothing is seriously broken.
  put "/api/v1/matches/#{@match.id}", params: {
    access_token: access_token,
    match: {
      name: 'Alternative String Value',
      # 🚅 super scaffolding will also insert new fields above this line.
    }
  }

  assert_response :success

  # Ensure all the required data is returned properly.
  assert_proper_object_serialization response.parsed_body

  # But we have to manually assert the value was properly updated.
  @match.reload
  assert_equal @match.name, 'Alternative String Value'
  # 🚅 super scaffolding will additionally insert new fields above this line.

  # Also ensure we can't do that same action as another user.
  put "/api/v1/matches/#{@match.id}", params: {access_token: another_access_token}
  assert_response :not_found
end

test "destroy" do
  # Delete and ensure it actually went away.
  assert_difference("Match.count", -1) do
    delete "/api/v1/matches/#{@match.id}", params: {access_token: access_token}
    assert_response :success
  end

  # Also ensure we can't do that same action as another user.
  delete "/api/v1/matches/#{@another_match.id}", params: {access_token: another_access_token}
  assert_response :not_found
end
end
