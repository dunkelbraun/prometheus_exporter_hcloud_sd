# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "prometheus_exporter_hcloud_sd"

require "minitest/autorun"
require "mocha/minitest"

require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.filter_sensitive_data("<BEARER_TOKEN>") do |interaction|
    auths = interaction.request.headers["Authorization"].first
    if (match = auths.match(/^Bearer\s+([^,\s]+)/))
      match.captures.first
    end
  end
  config.hook_into :webmock
end

class ThorTestCase < Minitest::Test
  StreamCapture = Struct.new(:stdout, :stderr, :original_stdout, :original_stderr)

  def run_cli_command(*args)
    stream_capture = capture_streams
    begin
      status = 0
      PrometheusExporterHcloudSd::CLI.start(args)
    rescue SystemExit
      status = 1
    end
    rewind_streams && [$stdout.read, $stderr.read, status]
  ensure
    cleanup_streams(stream_capture)
  end

  private

  def capture_streams
    original_stdout = $stdout.dup
    original_stderr = $stderr.dup
    stdout_capture = Tempfile.new("stdout")
    stderr_capture = Tempfile.new("stderr")

    $stdout.reopen(stdout_capture)
    $stderr.reopen(stderr_capture)
    StreamCapture.new(stdout_capture, stderr_capture, original_stdout, original_stderr)
  end

  def cleanup_streams(stream_capture)
    rewind_streams
    $stdout.reopen(stream_capture.original_stdout)
    $stderr.reopen(stream_capture.original_stderr)
    [stream_capture.stdout, stream_capture.stderr].map(&:close)
  end

  def rewind_streams
    [$stdout, $stderr].map(&:rewind)
  end
end
