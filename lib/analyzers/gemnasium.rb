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

    REPORT_NAME = 'gl-sast-gemnasium.json'.freeze
    CLIENT_URL = 'https://gitlab.com/gitlab-org/security-products/binaries/raw/master/gemnasium-client/gemnasium-client-1.0.1'.freeze
    CLIENT_PATH = '/app/bin/gemnasium'.freeze

    attr_reader :app, :report_path

    def initialize(app)
      @app = app
      @report_path = File.join(@app.path, REPORT_NAME)
    end

    def found_technology?
      install_client

      Dir.chdir(@app.path) do
        cmd <<-SH
        [ ! -z "$(#{CLIENT_PATH} search .)" ]
        SH
      end
    end

    def execute
      install_client
      output = analyze
      output_to_issues(output)
    end

    private

    def install_client
      return if File.file?(CLIENT_PATH)
      cmd <<-SH
        mkdir -p #{File.dirname(CLIENT_PATH)}
        curl #{CLIENT_URL} --output #{CLIENT_PATH}
        chmod a+rx #{CLIENT_PATH}
      SH
    end

    def analyze
      Dir.chdir(@app.path) do
        cmd <<-SH
        #{CLIENT_PATH} alerts . > #{report_path}
        SH

        JSON.parse(File.read(report_path))
      end
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
