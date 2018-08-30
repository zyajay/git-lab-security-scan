# frozen_string_literal: true

require_relative 'helpers'
require_relative '../issue'

module Analyzers
  # Language: Javascript
  # Framework: Any
  # Detecting the use of JavaScript libraries with known vulnerabilities
  class NPMAudit
    include Analyzers::Helpers

    REPORT_NAME = 'gl-sast-npm-audit.json'

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
          npm audit --json > #{report_path}
        SH

        parse_output(File.read(report_path))
      end
    ensure
      File.delete(report_path) if File.exist?(report_path)
    end

    def parse_output(output)
      json = JSON.parse(output)
      json['advisories'].map do |advisory|
        findings = advisory[1]
        result = {}
        result[:message] = findings['title'].strip + "\n\n" + findings['overview'].strip
        cves = findings['cves']
        result[:cve] = cves&.first
        result[:cwe] = findings['cwe']
        result[:solution] = findings['recommendation'].strip
        result[:url] = findings['url']
        result[:priority] =
          case findings['severity']
          when 'Low'
            'Low'
          when 'Moderate'
            'Medium'
          else
            'High'
          end

        result
      end.compact
    end

    def analyzed_file
      @analyzed_file ||=
        if File.exist?('npm-shrinkwrap.json')
          'npm-shrinkwrap.json'
        else
          'package-lock.json'
        end
    end

    def output_to_issues(output)
      output.map do |result|
        issue = Issue.new
        issue.tool = :npm_audit
        issue.message = result[:message]
        issue.url = result[:url]
        # Ensure we have a value for CVE as Frontend expects one
        issue.cve = result[:cve] || result[:cwe] || result[:message]
        issue.file = analyzed_file
        issue.solution = result[:solution]
        issue.priority = result[:priority]
        issue
      end
    end
  end
end
