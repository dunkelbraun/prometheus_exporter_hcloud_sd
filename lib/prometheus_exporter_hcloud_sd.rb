# frozen_string_literal: true

require "thor"
require_relative "prometheus_exporter_hcloud_sd/version"

module PrometheusExporterHcloudSd
  class Error < StandardError; end

  class CLI < Thor
    include Thor::Actions

    source_paths << File.expand_path("lib/prometheus_exporter_hcloud_sd/recipes")

    def self.exit_on_failure?
      true
    end

    desc "discover", "Discover Prometheus exporters in your Hetzner Cloud project."
    long_desc <<~LONGDESC
      `prometheus_exporter_hcloud_sd discover` will print out a YAML configuration for discovered Prometheus exporters
      in your Hetzner Cloud project using the Hetzner Cloud API.

      To authenticate with the API, set the `HCLOUD_READ_TOKEN` environment variable with an API token that has read
      permissions.

      Needs to be run inside the same network as the servers (uses the private IP of the servers).

      > $ HCLOUD_READ_TOKEN=your-read-token prometheus_exporter_hcloud_sd discover

      - targets: ["10.15.1.1:9104"]

          labels:

            job: "mysql"

      - targets: ["10.15.1.2:9121","10.15.1.3:9121"]

        labels:

          job: "redis"
    LONGDESC
    def discover
      apply "discover.rb", verbose: false
    end
  end
end
