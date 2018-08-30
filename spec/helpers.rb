# frozen_string_literal: true

require_relative '../lib/technology'
require_relative '../lib/technologies'

module Helpers
  C_REPO = 'https://gitlab.com/gitlab-org/security-products/tests/c.git'
  CPLUSPLUS_REPO = 'https://gitlab.com/gitlab-org/security-products/tests/cplusplus.git'
  RUBY_REPO = 'https://gitlab.com/gitlab-org/gl-sast'
  RAILS_REPO = 'https://gitlab.com/dzaporozhets/sast-sample-rails.git'
  RAILS_YARN_REPO = 'https://gitlab.com/groulot/sast-test-rails-and-yarn.git'
  JS_YARN_REPO = 'https://gitlab.com/dz-test-sast/ghost.git'
  JS_NPM_REPO = 'https://gitlab.com/gitlab-org/security-products/tests/js-npm.git'
  PY_REPO = 'https://gitlab.com/dz-test-sast/django-cms'
  PY_NO_VULN_REPO = 'https://gitlab.com/groulot/sast-test-python-no-vulnerability.git'
  MAVEN_REPO = 'https://gitlab.com/gitlab-org/security-products/tests/java-maven.git'

  def git_clone(url, dir)
    path = File.join(File.expand_path(File.dirname(__FILE__)), '../tmp', dir)
    `git clone #{url} #{path}` unless Dir.exist?(path)
    path
  end

  def clone_c_app
    git_clone(C_REPO, 'c-app')
  end

  def clone_cplusplus_app
    git_clone(CPLUSPLUS_REPO, 'cplusplus-app')
  end

  def clone_ruby_app
    git_clone(RUBY_REPO, 'rb-app')
  end

  def clone_rails_yarn_app
    git_clone(RAILS_YARN_REPO, 'rails-yarn-app')
  end

  def clone_rails_app
    git_clone(RAILS_REPO, 'rails-app')
  end

  def clone_js_npm_app
    git_clone(JS_NPM_REPO, 'js-npm-app')
  end

  def clone_js_yarn_app
    git_clone(JS_YARN_REPO, 'js-yarn-app')
  end

  def clone_maven_app
    git_clone(MAVEN_REPO, 'maven-app')
  end

  def clone_py_app
    git_clone(PY_REPO, 'py-app')
  end

  def clone_py_no_vuln_app
    git_clone(PY_NO_VULN_REPO, 'py-no-vuln-app')
  end

  def c_techs
    techs = Technologies.new
    techs.add(Technology.new(:c))
    techs
  end

  def cplusplus_techs
    techs = Technologies.new
    techs.add(Technology.new(:cplusplus))
    techs
  end

  def python_techs
    techs = Technologies.new
    techs.add(Technology.new(:python))
    techs
  end

  def rails_techs
    techs = Technologies.new
    techs.add(
      Technology.new(
        :ruby,
        package_manager: :bundler,
        framework: :rails
      )
    )
    techs
  end

  def js_npm_techs
    techs = Technologies.new
    techs.add(
      Technology.new(
        :js,
        package_manager: :npm
      )
    )
    techs
  end

  def js_yarn_techs
    techs = Technologies.new
    techs.add(
      Technology.new(
        :js,
        package_manager: :npm
      )
    )
    techs
  end

  def java_maven_techs
    techs = Technologies.new
    techs.add(
      Technology.new(
        :java,
        package_manager: :maven
      )
    )
    techs
  end

  def ruby_techs
    techs = Technologies.new
    techs.add(
      Technology.new(
        :ruby,
        package_manager: :bundler
      )
    )
    techs
  end

  def issue_for(tool)
    issue = Issue.new
    issue.tool = tool

    issue
  end

  def mock_analyzer_output(analyzer, file_path)
    Bundler.with_clean_env do
      allow(analyzer).to receive(:cmd).at_least(:once) do
        # Do nothing
      end

      # Copy the file into the place where the cmd output would go normally.
      FileUtils.copy(file_path, analyzer.report_path)
      analyzer.execute
    end
  end

  # Returns the full path of a file in the spec/fixtures/files directory
  def file_fixture_path(filename)
    File.join(RSpec::Core::RubyProject.determine_root, 'spec/fixtures/files', filename)
  end
end
