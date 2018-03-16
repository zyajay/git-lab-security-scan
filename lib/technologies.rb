require 'set'
require 'find'
require 'forwardable'
require_relative 'technology'

# A set of technologies and convenient methods to query it
class Technologies
  extend Forwardable

  DOCKER_SOCKET_PATH = '/var/run/docker.sock'.freeze

  attr_reader :technologies

  def_delegators :@technologies, :add

  def initialize
    @technologies = Set.new([])
  end

  def any?
    @technologies.any?
  end

  def language?(name)
    @technologies.any? { |t| t.language?(name) }
  end

  def package_manager?(name)
    @technologies.any? { |t| t.package_manager?(name) }
  end

  def framework?(name)
    @technologies.any? { |t| t.framework?(name) }
  end

  def technology?(tech)
    @technologies.include?(tech)
  end

  # Given the path of a project, detect technologies used in the project
  def self.detect_technologies(path)
    techs = Technologies.new
    files = Dir.entries(path)

    if files.include?('Gemfile.lock')
      techs.add(Technology.ruby_bundler)
      # check for Rails
      content = File.read(File.join(path, 'Gemfile.lock'))
      techs.add(Technology.rails) if content.include?(' rails ')
    end

    if files.include?('yarn.lock')
      techs.add(Technology.js_yarn)
    elsif files.include?('package.json')
      # consider it's npm (may use package-lock.json or npm-shrinkwrap.json)
      techs.add(Technology.js_npm)
    end

    if files.include?('setup.py') || files.include?('Pipfile') ||
       files.include?('requires.txt') || files.include?('requirements.txt') ||
       files.include?('requirements.pip')
      techs.add(Technology.python_pip)
    end

    # Look into directory tree for C files
    techs.add(Technology.c) if search_for_files(path, /.*\.c$/)

    # Look into directory tree for C++ files
    techs.add(Technology.cplusplus) if search_for_files(path, /.*\.(c|cc|cpp|c\+\+|cp|cxx)$/i)

    techs.add(Technology.php_composer) if files.include?('composer.lock')

    techs.add(Technology.java_maven) if files.include?('pom.xml')

    techs
  end

  # Check that the requirements for each technology are present in the system.
  # Returns a list of warnings if not
  def requirement_warnings
    warnings = []
    dind_is_needed = 'Docker-in-Docker is needed. Please update your .gitlab-ci.yml file. See : https://docs.gitlab.com/ee/ci/examples/sast.html'.freeze

    if package_manager?(:maven) && !docker_available?
      # The Gemnasium client requires docker to check dependencies for Maven projects
      warnings << "To check your Maven packages dependencies, #{dind_is_needed}"
    end

    if language?(:python) && !docker_available?
      # The Gemnasium client requires docker to get the list of python packages
      warnings << "To check your Python packages dependencies, #{dind_is_needed}"
    end

    warnings
  end

  private

  def docker_available?
    File.socket?(DOCKER_SOCKET_PATH)
  end

  # Look into subdirectories for files
  def self.search_for_files(path, regex)
    Find.find(path) do |file|
      return true if file =~ regex
    end

    false
  end

  private_class_method :search_for_files
end
