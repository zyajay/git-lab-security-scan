# A technology gathers a framework, package manager and a language together
class Technology
  attr_reader :language, :package_manager, :framework

  def self.ruby_bundler
    Technology.new(:ruby, :bundler)
  end

  def self.rails
    Technology.new(:ruby, :bundler, :rails)
  end

  def self.js_npm
    Technology.new(:js, :npm)
  end

  def self.js_yarn
    Technology.new(:js, :yarn)
  end

  def self.python_pip
    Technology.new(:python, :pip)
  end

  def self.php_composer
    Technology.new(:php, :composer)
  end

  def self.java_maven
    Technology.new(:java, :maven)
  end

  def self.c
    Technology.new(:c)
  end

  def self.cplusplus
    Technology.new(:cplusplus)
  end

  def initialize(language, package_manager = nil, framework = nil)
    @language = language
    @package_manager = package_manager
    @framework = framework
  end

  def eql?(other)
    @language == other.language &&
      @package_manager == other.package_manager &&
      @framework == other.framework
  end

  def hash
    @language.hash + @package_manager.hash + @framework.hash
  end

  def language?(name)
    name == @language
  end

  def package_manager?(name)
    name == @package_manager
  end

  def framework?(name)
    name == @framework
  end
end
