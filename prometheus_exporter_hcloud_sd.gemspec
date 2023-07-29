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
  spec.metadata["source_code_uri"] = "https://github.com/dunkelbraun/turbo_test_events/tree/main"
  spec.metadata["changelog_uri"] = "https://github.com/dunkelbraun/prometheus_exporter_hcloud_sd/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rubocop-minitest"
  spec.add_development_dependency "rubocop-rake"
  # spec.add_development_dependency "rubocop-minitest"
  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
