# frozen_string_literal: true

require_relative 'helpers'
require_relative '../issue'

module Analyzers
  # Language: Ruby
  # Framework: Any
  # Patch-level verification for Bundler.
  # - Checks for vulnerable versions of gems in Gemfile.lock.
  # - Checks for insecure gem sources (http://).
  class BundleAudit
    include Analyzers::Helpers

    REPORT_NAME = 'gl-sast-bundle-audit.json'

    attr_reader :app, :report_path

    def initialize(app)
      @app = app
      @report_path = File.join(@app.path, REPORT_NAME)
    end

    def execute
      output = analyze
      output_to_issues(output)
    end

    private

    def analyze
      Dir.chdir(@app.path) do
        cmd <<-SH
          gem install bundler-audit
          bundle audit check --update --quiet > #{report_path}
        SH

        parse_output(File.read(report_path))
      end
    ensure
      File.delete(report_path) if File.exist?(report_path)
    end

    def parse_output(output)
      output.split(/\n\n/).map do |record|
        next unless record.start_with?('Name: ')

        lines = record.split(/\n/)
        result = {}

        lines.each do |line|
          if line.start_with?('Title: ')
            result[:message] = line.sub('Title: ', '')
          elsif line.start_with?('Advisory: ')
            result[:cve] = line.sub('Advisory: ', '')
          elsif line.start_with?('Solution: ')
            result[:solution] = line.sub('Solution: ', '')
          elsif line.start_with?('URL: ')
            result[:url] = line.sub('URL: ', '')
          elsif line.start_with?('Criticality: ')
            result[:priority] = line.sub('Criticality: ', '')
          end
        end

        result
      end.compact
    end

    def output_to_issues(output)
      output.map do |result|
        issue = Issue.new
        issue.tool = :bundler_audit
        issue.message = result[:message]
        issue.url = result[:url]
        # Ensure we have a value for CVE as Frontend expects one
        issue.cve = result[:cve] || result[:message]
        issue.file = 'Gemfile.lock'
        issue.solution = result[:solution]
        issue.priority = result[:priority]
        issue
      end
    end
  end
end
