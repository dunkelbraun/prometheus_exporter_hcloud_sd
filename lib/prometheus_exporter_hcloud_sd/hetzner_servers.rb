require "json"
require "net/http"
require "uri"

module PrometheusExporterHcloudSd
  module HetznerServers
    SERVERS_URI = URI.parse("https://api.hetzner.cloud/v1/servers").freeze

    def self.private_ips
      token = ENV.fetch("HCLOUD_READ_TOKEN")
      response = Net::HTTP.get(SERVERS_URI, { Authorization: "Bearer #{token}" })
      json_response = JSON.parse(response, symbolize_names: true)

      json_response.fetch(:servers, []).map do |server|
        server.fetch(:private_net, [{}]).first.fetch(:ip, nil)
      end.compact
    rescue KeyError
      raise Thor::Error, "Cannot continue.\nPlease set the HCLOUD_READ_TOKEN environment variable."
    end
  end
end
