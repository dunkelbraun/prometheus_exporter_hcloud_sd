# frozen_string_literal: true

require "test_helper"

class TestDiscoverCommand < ThorTestCase
  def test_discover_command
    stdout, _stderr, status = run_cli_command("discover")

    assert_equal 0, status
    assert_equal "Discovering exporters in your Hetzner Cloud project...\n", stdout
  end
end
