require "json"
require "open3"
require_relative "hetzner_servers"

module PrometheusExporterHcloudSd
  class DiscoveryConfig
    PORTS = {
      "9104" => :mysql,
      "9121" => :redis,
      "9114" => :elastic_search,
      "9187" => :postgres,
      "9127" => :pgbouncer
    }.freeze

    def self.generate(options)
      new(options).generate
    end

    def initialize(options)
      @additional_ports = options[:exporter].each_with_object({}) do |exporter, acc|
        service, port = exporter.split("=")
        acc[port] = service.to_sym
      end
    end

    def generate
      server_ips = PrometheusExporterHcloudSd::HetznerServers.private_ips
      output = ""

      PORTS.merge(@additional_ports).each do |port, service|
        available_servers = discover_exporters(server_ips: server_ips, port: port)

        next if available_servers.none?

        output << target_configuration(service: service, available_servers: available_servers)
      end
      output
    end

    def discover_exporters(server_ips:, port:)
      server_ips.collect do |ip|
        command = "timeout 1 nc -zv #{ip} #{port}"
        _, status = Open3.capture2e(command)
        status.success? ? "#{ip}:#{port}" : nil
      end.compact
    end

    def target_configuration(service:, available_servers:)
      <<~LINE
        - targets: #{available_servers.to_json}
          labels:
            job: "#{service}"
      LINE
    end
  end
end
