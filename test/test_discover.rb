# frozen_string_literal: true

require "test_helper"
require "open3"

class TestDiscoverCommand < ThorTestCase
  def test_discover_command_with_no_api_authetication
    VCR.use_cassette("hetzner_api_servers_no_auth") do
      stdout, _stderr, status = run_cli_command("discover")

      assert_equal 0, status

      assert_equal "\n", stdout
    end
  end

  def test_discover_command_with_authetication_but_no_servers
    VCR.use_cassette("hetzner_api_servers_no_servers") do
      stdout, _stderr, status = run_cli_command("discover")

      assert_equal 0, status

      assert_equal "\n", stdout
    end
  end

  def test_discover_command
    VCR.use_cassette("hetzner_api_servers_auth") do
      Open3.expects(:capture2e).with("timeout 1 nc -zv 10.15.1.1 9104").returns(["", mock(success?: true)])
      Open3.expects(:capture2e).with("timeout 1 nc -zv 10.15.1.1 9121").returns(["", mock(success?: false)])
      Open3.expects(:capture2e).with("timeout 1 nc -zv 10.15.1.1 9114").returns(["", mock(success?: false)])
      Open3.expects(:capture2e).with("timeout 1 nc -zv 10.15.1.1 9187").returns(["", mock(success?: true)])
      Open3.expects(:capture2e).with("timeout 1 nc -zv 10.15.1.1 9127").returns(["", mock(success?: true)])

      Open3.expects(:capture2e).with("timeout 1 nc -zv 10.15.1.2 9104").returns(["", mock(success?: false)])
      Open3.expects(:capture2e).with("timeout 1 nc -zv 10.15.1.2 9121").returns(["", mock(success?: true)])
      Open3.expects(:capture2e).with("timeout 1 nc -zv 10.15.1.2 9114").returns(["", mock(success?: false)])
      Open3.expects(:capture2e).with("timeout 1 nc -zv 10.15.1.2 9187").returns(["", mock(success?: true)])
      Open3.expects(:capture2e).with("timeout 1 nc -zv 10.15.1.2 9127").returns(["", mock(success?: false)])

      Open3.expects(:capture2e).with("timeout 1 nc -zv 10.15.1.3 9104").returns(["", mock(success?: false)])
      Open3.expects(:capture2e).with("timeout 1 nc -zv 10.15.1.3 9121").returns(["", mock(success?: true)])
      Open3.expects(:capture2e).with("timeout 1 nc -zv 10.15.1.3 9114").returns(["", mock(success?: true)])
      Open3.expects(:capture2e).with("timeout 1 nc -zv 10.15.1.3 9187").returns(["", mock(success?: false)])
      Open3.expects(:capture2e).with("timeout 1 nc -zv 10.15.1.3 9127").returns(["", mock(success?: false)])

      stdout, _stderr, status = run_cli_command("discover")

      assert_equal 0, status

      expected = <<~OUTPUT
        - targets: ["10.15.1.1:9104"]
          labels:
            job: "mysql"
        - targets: ["10.15.1.2:9121","10.15.1.3:9121"]
          labels:
            job: "redis"
        - targets: ["10.15.1.3:9114"]
          labels:
            job: "elastic_search"
        - targets: ["10.15.1.1:9187","10.15.1.2:9187"]
          labels:
            job: "postgres"
        - targets: ["10.15.1.1:9127"]
          labels:
            job: "pgbouncer"
      OUTPUT

      assert_equal expected, stdout
    end
  end
end
