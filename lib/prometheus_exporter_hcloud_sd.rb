# frozen_string_literal: true

require "thor"
require_relative "prometheus_exporter_hcloud_sd/version"

module PrometheusExporterHcloudSd
  class Error < StandardError; end

  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc "discover", "Discover Prometheus exporters in your Hetzner Cloud project."
    def discover
      puts "Discovering exporters in your Hetzner Cloud project..."
    end
  end
end
