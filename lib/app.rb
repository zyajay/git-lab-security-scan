require_relative 'technologies'

# Collect information about source code like programming language and framework
class App
  attr_reader :technologies, :path

  def initialize(path)
    @path = File.expand_path(path)

    @technologies = Technologies.detect_technologies(path)
  end
end
