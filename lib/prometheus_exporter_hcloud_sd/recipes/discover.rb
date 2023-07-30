require "json"
require "net/http"
require "uri"
require "open3"

SERVERS_URI = URI.parse("https://api.hetzner.cloud/v1/servers").freeze
token = begin
  ENV.fetch("HCLOUD_READ_TOKEN")
rescue KeyError
  raise Thor::Error, "Cannot continue.\nPlease set the HCLOUD_READ_TOKEN environment variable."
end

AUTH_HEADER = { Authorization: "Bearer #{token}" }.freeze

response = Net::HTTP.get(SERVERS_URI, AUTH_HEADER)
json_response = JSON.parse(response, symbolize_names: true)

server_ips = json_response.fetch(:servers, []).map do |server|
  server.fetch(:private_net, [{}]).first.fetch(:ip, nil)
end.compact

PORTS = {
  "9104" => :mysql,
  "9121" => :redis,
  "9114" => :elastic_search,
  "9187" => :postgres,
  "9127" => :pgbouncer
}.freeze

output = ""

additional_ports = options[:exporter].each_with_object({}) do |exporter, acc|
  service, port = exporter.split("=")
  acc[port] = service.to_sym
end

PORTS.merge(additional_ports).each do |port, service|
  available_servers = server_ips.collect do |ip|
    command = "timeout 1 nc -zv #{ip} #{port}"
    _, status = Open3.capture2e(command)
    status.success? ? "#{ip}:#{port}" : nil
  end.compact

  next if available_servers.none?

  output << <<~LINE
    - targets: #{available_servers.to_json}
      labels:
        job: "#{service}"
  LINE
end

puts output
