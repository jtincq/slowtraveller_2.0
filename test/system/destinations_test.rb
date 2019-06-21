require "application_system_test_case"

class DestinationsTest < ApplicationSystemTestCase
  test "visiting the home" do
    visit "/"
    assert_selector "h1", text: "Slow Traveller"
  end
end
