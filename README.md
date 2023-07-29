# prometheus_exporter_hcloud_sd

prometheus_exporter_hcloud_sd is a CLI tool that discovers Prometheus exporters in your Hetzner Cloud project and generates a Prometeus file-based service discovery YAML configuration for them.

## Description

This tool is particularly useful when running multiple Prometheus exporters in a Hetzner Cloud environment and you want to automate the discovery and configuration process.

`prometheus_exporter_hcloud_sd` utilizes the Hetzner Cloud API for exporter discovery. Therefore, it should be executed within the same network as the servers (it discovers exporters using the servers' private IP).

By default, the tool will discover the following exporters:

- MySQL at port 9104
- Redis at port 9121
- ElasticSearch at port 9114
- Postgres at port 9187
- PgBouncer at port 9127

You can specify additional exporters to discover with the `--exporter` flag, followed by the service name and port, formatted as: `<service_name>=<port>`.

## Installation

Install the gem with:

```bash
gem install prometheus_exporter_hcloud_sd
```

If you use bundler to manage dependencies, install the gem by executing:

```bash
bundle add prometheus_exporter_hcloud_sd
```

## Usage

Before using `prometheus_exporter_hcloud_sd`, ensure the `HCLOUD_READ_TOKEN` environment variable is set with a Hetzner Cloud API token that has read permissions.

```bash
export HCLOUD_READ_TOKEN=your-read-token
```

Run the following command to discover exporters:

```bash
prometheus_exporter_hcloud_sd discover
```

The following is an example of a generated YAML configuration:

```yaml
- targets: ["10.15.1.1:9104"]
  labels:
    job: "mysql"

- targets: ["10.15.1.2:9121","10.15.1.3:9121"]
  labels:
    job: "redis"
```

This YAML configuration can be used to set up the a file-based service discovery in Prometheus. For example, you can create a file called `hcloud_sd.yml` with the above content and then configure Prometheus to use it:

```yaml
scrape_configs:
- job_name: 'node'
  file_sd_configs:
  - files:
    - 'hcloud_sd.yml'
```

To discover additional exporters, use the --exporter flag (can be used multiple times):

```bash
prometheus_exporter_hcloud_sd discover --exporter traefik=80
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/dunkelbraun/prometheus_exporter_hcloud_sd>.

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/dunkelbraun/prometheus_exporter_hcloud_sd/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PrometheusExporterHcloudSd project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/dunkelbraun/prometheus_exporter_hcloud_sd/blob/main/CODE_OF_CONDUCT.md).
