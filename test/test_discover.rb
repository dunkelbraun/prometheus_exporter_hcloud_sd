# frozen_string_literal: true

require "test_helper"
require "open3"

class TestDiscoverCommand < ThorTestCase
  def test_discover_command_with_no_api_authetication
    VCR.use_cassette("hetzner_api_servers_no_auth") do
      ClimateControl.modify(HCLOUD_READ_TOKEN: "some-token") do
        stdout, _stderr, status = run_cli_command("discover")

        assert_equal 0, status

        assert_equal "\n", stdout
      end
    end
  end

  def test_discover_command_with_authetication_but_no_servers
    VCR.use_cassette("hetzner_api_servers_no_servers") do
      ClimateControl.modify(HCLOUD_READ_TOKEN: "some-token") do
        stdout, _stderr, status = run_cli_command("discover")

        assert_equal 0, status

        assert_equal "\n", stdout
      end
    end
  end

  def test_discover_command
    VCR.use_cassette("hetzner_api_servers_auth") do
      mock_service("10.15.1.1", 9104, true)
      mock_service("10.15.1.1", 9121, false)
      mock_service("10.15.1.1", 9114, false)
      mock_service("10.15.1.1", 9187, true)
      mock_service("10.15.1.1", 9127, true)

      mock_service("10.15.1.2", 9104, false)
      mock_service("10.15.1.2", 9121, true)
      mock_service("10.15.1.2", 9114, false)
      mock_service("10.15.1.2", 9187, true)
      mock_service("10.15.1.2", 9127, false)

      mock_service("10.15.1.3", 9104, false)
      mock_service("10.15.1.3", 9121, true)
      mock_service("10.15.1.3", 9114, true)
      mock_service("10.15.1.3", 9187, false)
      mock_service("10.15.1.3", 9127, false)

      ClimateControl.modify(HCLOUD_READ_TOKEN: "some-token") do
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

  def test_discover_command_with_additional_exporters
    VCR.use_cassette("hetzner_api_servers_auth") do
      mock_service("10.15.1.1", 9104, true)
      mock_service("10.15.1.1", 9121, false)
      mock_service("10.15.1.1", 9114, false)
      mock_service("10.15.1.1", 9187, true)
      mock_service("10.15.1.1", 9127, true)
      mock_service("10.15.1.1", 80, false)
      mock_service("10.15.1.1", 9177, true)

      mock_service("10.15.1.2", 9104, false)
      mock_service("10.15.1.2", 9121, true)
      mock_service("10.15.1.2", 9114, false)
      mock_service("10.15.1.2", 9187, true)
      mock_service("10.15.1.2", 9127, false)
      mock_service("10.15.1.2", 80, true)
      mock_service("10.15.1.2", 9177, false)

      mock_service("10.15.1.3", 9104, false)
      mock_service("10.15.1.3", 9121, true)
      mock_service("10.15.1.3", 9114, true)
      mock_service("10.15.1.3", 9187, false)
      mock_service("10.15.1.3", 9127, false)
      mock_service("10.15.1.3", 80, false)
      mock_service("10.15.1.3", 9177, false)

      ClimateControl.modify(HCLOUD_READ_TOKEN: "some-token") do
        stdout, _stderr, status = run_cli_command("discover", "--exporter", "traefik=80", "--exporter", "test=9177")

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
          - targets: ["10.15.1.2:80"]
            labels:
              job: "traefik"
          - targets: ["10.15.1.1:9177"]
            labels:
              job: "test"
        OUTPUT

        assert_equal expected, stdout
      end
    end
  end

  def test_discover_command_wthouut_api_token_environment_variable
    _stdout, stderr, status = run_cli_command("discover")

    assert_equal 1, status
    assert_equal "Cannot continue.\nPlease set the HCLOUD_READ_TOKEN environment variable.\n", stderr
  end

  private

  def mock_service(ip_address, port, success)
    Open3.expects(:capture2e).with("timeout 1 nc -zv #{ip_address} #{port}").returns(["", mock(success?: success)])
  end
end
