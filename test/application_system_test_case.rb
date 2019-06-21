require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by driven_by :headless_chrome
end
