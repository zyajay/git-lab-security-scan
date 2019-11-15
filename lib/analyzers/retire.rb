require 'json'
require 'tmpdir'

require_relative 'helpers'
require_relative '../issue'

module Analyzers
  # Language: JavaScript
  # Framework: Any
  # Detecting the use of JavaScript libraries with known vulnerabilities
  class Retire
    include Analyzers::Helpers

    REPORT_NAME = 'gl-sast-retire.json'.freeze

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
          npm install -g retire@1.6.0
          retire --outputformat json --outputpath #{report_path}
        SH

        JSON.parse(File.read(report_path))
      end
    ensure
      File.delete(report_path) if File.exist?(report_path)
    end

    def output_to_issues(output)
      issues = []

      output.each do |record|
        filename = record.fetch('file', nil)

        record['results'].each do |result|
          puts ' x ' + result.inspect

          next unless result['vulnerabilities']

          result['vulnerabilities'].each do |vulnerability|
            issue = Issue.new
            issue.tool = :retire
            issue.url = vulnerability['info'].first
            if filename
              # Trim the absolute part of the path
              issue.file = filename.gsub(%r{^#{@app.path}\/}, '')
            end
            issue.priority = vulnerability['severity'].capitalize

            identifiers = vulnerability['identifiers']

            if identifiers
              issue.cve = identifiers['CVE'].first if identifiers['CVE']
              issue.message = (identifiers['summary'] ||
                'Vulnerability') + ' for ' + result['component']
            else
              issue.message = 'Vulnerability for ' + result['component']
            end

            issue.cve ||= issue.message

            issues << issue
          end
        end
      end

      issues
    end
  end
end
