require_relative 'analyzers/bundle_audit'
require_relative 'analyzers/gemnasium'
require_relative 'analyzers/retire'

# Run Dependency analyzer tools over source code
class Analyze
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def issues
    issues = []
    has_found_technology = false

    # Always run Gemnasium once for all technologies
    if ENV['SAST_DISABLE_REMOTE_CHECKS'] != 'true' && @app.technologies.any?
      analyzer = Analyzers::Gemnasium.new(app)

      if analyzer.found_technology?
        issues += analyzer.execute
        has_found_technology = true
      end
    end

    # Run bundle audit if Bundler is used
    if @app.technologies.package_manager?(:bundler)
      issues += Analyzers::BundleAudit.new(app).execute
      has_found_technology = true
    end

    # Run Retire.js for Javascript apps
    if @app.technologies.language?(:js)
      issues += Analyzers::Retire.new(app).execute
      has_found_technology = true
    end

    # Warns if nothing was analyzed
    not_supported unless has_found_technology

    issues.compact
  end

  private

  def not_supported
    puts 'Source code language/dependency manager is not yet supported for analyze'
    exit 1
  end
end
