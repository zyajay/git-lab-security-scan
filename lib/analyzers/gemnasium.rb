require 'json'
require 'tmpdir'

require_relative 'helpers'
require_relative '../issue'

module Analyzers
  # Language: Any
  # Framework: Any
  # Detecting the use of dependencies with known vulnerabilities
  class Gemnasium
    include Analyzers::Helpers

    class ProjectNotSupported < StandardError
    end

    REPORT_NAME = 'gl-dependency-scanning-report.json'.freeze
    GEMNASIUM_PATH = ENV.fetch('GEMNASIUM_PATH', "bin/gemnasium")
    SUPPORTED_DEPENDENCY_FILES = %w(composer.lock Gemfile.lock gems.locked maven-dependencies.json gemnasium-maven-plugin.json package-lock.json npm-shrinkwrap.json pipdeptree.json Pipfile.lock yarn.lock).freeze

    attr_reader :app, :report_path

    def initialize(app)
      @app = app
      @report_path = File.join(@app.path, REPORT_NAME)
    end

    def found_technology?
      (Dir.entries(@app.path) & SUPPORTED_DEPENDENCY_FILES).length > 0
    end

    def execute
      output = analyze
      output_to_issues(output)
    rescue ProjectNotSupported
      []
    end

    private

    def analyze
      cmd <<-SH
        DS_REMEDIATE=false CI_PROJECT_DIR=#{@app.path} #{GEMNASIUM_PATH} run
      SH
      status = $?.exitstatus
      if status == 3
        raise ProjectNotSupported
      elsif status != 0
        raise RuntimeError.new "unexpected exit status: #{status}"
      end
      JSON.parse(File.read(report_path))
    ensure
      File.delete(report_path) if File.exist?(report_path)
    end

    def output_to_issues(output)
      issues = []

      output['vulnerabilities'].each do |advisory|

        issue = Issue.new
        issue.tool = :gemnasium

        # extract URL of first link
        if links = advisory['links']
          if link = links[0]
            issue.url = link['url']
          end
        end

        # extract location, solution, message
        issue.file = advisory['location']['file']
        issue.solution = advisory['solution']
        issue.message = advisory['message']

        # NOTE: priority is hard-coded
        issue.priority = 'Unknown'

        # extract CVE id, use message if missing
        cve_identifier = advisory['identifiers'].find do |identifier|
          identifier['type'] == "cve"
        end
        if cve_identifier
          issue.cve = cve_identifier['value']
        else
          issue.cve = issue.message
        end

        issues << issue
      end

      issues = issues.uniq
      issues
    end
  end
end
