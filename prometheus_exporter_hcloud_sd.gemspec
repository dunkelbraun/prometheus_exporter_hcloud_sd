# frozen_string_literal: true

require_relative "lib/prometheus_exporter_hcloud_sd/version"

Gem::Specification.new do |spec|
  spec.name = "prometheus_exporter_hcloud_sd"
  spec.version = PrometheusExporterHcloudSd::VERSION
  spec.authors = ["Marcos Essindi"]
  spec.email = ["marcessindi@me.com"]

  spec.summary = "Discovers exporters running on instances in your Hetzner Cloud project."
  spec.homepage = "https://github.com/dunkelbraun/prometheus_exporter_hcloud_sd"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata["rubygems_mfa_required"] = "true"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/dunkelbraun/prometheus_exporter_hcloud_sd/tree/main"
  spec.metadata["changelog_uri"] = "https://github.com/dunkelbraun/prometheus_exporter_hcloud_sd/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = %w[prometheus_exporter_hcloud_sd]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "climate_control", "~> 1.2"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "mocha", "~> 2.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "rubocop-minitest", "~> 0.31"
  spec.add_development_dependency "rubocop-rake", "~> 0.6"
  spec.add_development_dependency "rubycritic", "~> 4.8"
  spec.add_development_dependency "simplecov", "~> 0.22.0"
  spec.add_development_dependency "vcr", "~> 6.2"
  spec.add_development_dependency "webmock", "~> 3.18"

  spec.add_dependency "thor", "~> 1.2"
end
