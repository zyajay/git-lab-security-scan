require 'json'
require 'tmpdir'
require 'English'

require_relative 'helpers'
require_relative '../issue'

module Analyzers
  # Language: Any
  # Framework: Any
  # Detecting the use of dependencies with known vulnerabilities
  class Gemnasium
    include Analyzers::Helpers

    class ProjectNotSupported < StandardError; end
    class UnexpectedExitStatus < StandardError; end

    REPORT_NAME = 'gl-dependency-scanning-report.json'.freeze

    GEMNASIUM_CLI_PATH = ENV.fetch('GEMNASIUM_CLI_PATH', 'bin/gemnasium')
    GEMNASIUM_MAVEN_IMAGE = ENV.fetch('GEMNASIUM_MAVEN_IMAGE', 'gemnasium-maven')
    GEMNASIUM_PYTHON_IMAGE = ENV.fetch('GEMNASIUM_PYTHON_IMAGE', 'gemnasium-python')
    DOCKER_SOCKET_PATH = '/var/run/docker.sock'.freeze

    GEMNASIUM_SUPPORTED_DEPENDENCY_FILES = %w[
      composer.lock Gemfile.lock gems.locked maven-dependencies.json
      gemnasium-maven-plugin.json package-lock.json npm-shrinkwrap.json
      pipdeptree.json Pipfile.lock yarn.lock
    ].freeze

    GEMNASIUM_MAVEN_SUPPORTED_DEPENDENCY_FILES = %w[pom.xml].freeze

    GEMNASIUM_PYTHON_SUPPORTED_DEPENDENCY_FILES = %w[
      requirements.txt requirements.pip Pipfile requires.txt setup.py
    ].freeze

    DOCKER_MOUNT_DIR = '/tmp/app'.freeze

    attr_reader :app, :report_path

    def initialize(app)
      @app = app
      @report_path = File.join(@app.path, REPORT_NAME)
    end

    def found_technology?
      supported_by_gemnasium? || supported_by_gemnasium_maven? || supported_by_gemnasium_python?
    end

    def execute
      output = []
      output += analyze_with_cli if supported_by_gemnasium?
      output += analyze_with_image(GEMNASIUM_MAVEN_IMAGE) if supported_by_gemnasium_maven?
      output += analyze_with_image(GEMNASIUM_PYTHON_IMAGE) if supported_by_gemnasium_python?
      output
    rescue ProjectNotSupported
      []
    end

    private

    def supported_by_gemnasium?
      (Dir.entries(@app.path) & GEMNASIUM_SUPPORTED_DEPENDENCY_FILES).any?
    end

    def supported_by_gemnasium_maven?
      docker_available? &&
        (Dir.entries(@app.path) & GEMNASIUM_MAVEN_SUPPORTED_DEPENDENCY_FILES).any?
    end

    def supported_by_gemnasium_python?
      docker_available? &&
        (Dir.entries(@app.path) & GEMNASIUM_PYTHON_SUPPORTED_DEPENDENCY_FILES).any?
    end

    def analyze_with_cli
      run_cmd do
        cmd <<-SH
          DS_REMEDIATE=false CI_PROJECT_DIR=#{@app.path} #{GEMNASIUM_CLI_PATH} run
        SH
      end
    end

    def analyze_with_image(image)
      # A bind mount cannot be used because it requires to known
      # the "full or relative path on the host machine"
      # (see https://docs.docker.com/storage/bind-mounts/)
      # but the job definition does not propagate $CI_PROJECT_DIR.
      run_cmd do
        cmd <<-SH
          set -e
          export CONTAINER_ID=$(docker create --volume /var/run/docker.sock:/var/run/docker.sock -e CI_PROJECT_DIR=#{DOCKER_MOUNT_DIR} #{image})
          docker cp #{@app.path} $CONTAINER_ID:#{DOCKER_MOUNT_DIR}
          docker start -i $CONTAINER_ID
          docker cp $CONTAINER_ID:#{DOCKER_MOUNT_DIR}/#{REPORT_NAME} #{@app.path}
          docker stop $CONTAINER_ID
          docker rm $CONTAINER_ID
        SH
      end
    end

    def run_cmd
      yield
      status = $CHILD_STATUS.exitstatus
      raise ProjectNotSupported if status == 3
      if status != 0
        raise UnexpectedExitStatus, "unexpected exit status: #{status}"
      end
      output_to_issues JSON.parse File.read report_path
    ensure
      File.delete(report_path) if File.exist?(report_path)
    end

    def output_to_issues(output)
      issues = []

      output['vulnerabilities'].each do |advisory|
        issue = Issue.new
        issue.tool = :gemnasium

        # extract URL of first link
        links = advisory['links']
        issue.url = links[0]['url'] if links && links.any?

        # extract location, solution, message
        issue.file = advisory['location']['file']
        issue.solution = advisory['solution']
        issue.message = advisory['message']

        # NOTE: priority is hard-coded
        issue.priority = 'Unknown'

        # extract CVE id, use message if missing
        cve_identifier = advisory['identifiers'].find do |identifier|
          identifier['type'] == 'cve'
        end
        issue.cve = cve_identifier ? cve_identifier['value'] : issue.message

        issues << issue
      end

      issues = issues.uniq
      issues
    end

    def docker_available?
      File.socket?(DOCKER_SOCKET_PATH)
    end
  end
end
