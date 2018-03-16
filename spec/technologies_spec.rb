require_relative '../lib/technologies'
require 'rspec'

RSpec.describe Technologies do
  let(:technologies) do
    Technologies.detect_technologies(app_path)
  end

  context '"with a C app' do
    let!(:app_path) { clone_c_app }

    it 'detects the C language technology' do
      expect(technologies).to satisfy { |ts|
        ts.technology?(Technology.new(:c))
      }
    end
  end

  context '"with a C++ app' do
    let!(:app_path) { clone_cplusplus_app }

    it 'detects the C++ language technology' do
      expect(technologies).to satisfy { |ts|
        ts.technology?(Technology.new(:cplusplus))
      }
    end
  end

  context '"with a C app in a subdirectory' do
    let!(:app_path) { file_fixture_path('c_app_in_subdirectory') }

    it 'detects the C language technology' do
      expect(technologies).to satisfy { |ts|
        ts.technology?(Technology.new(:c))
      }
    end
  end

  context '"with a Rails app' do
    let!(:app_path) { clone_rails_app }

    it 'detects the Ruby, Bundler and Rails technology' do
      expect(technologies).to satisfy { |ts|
        ts.technology?(Technology.new(:ruby, :bundler, :rails))
      }
    end
  end

  context 'with a Javascript NPM app' do
    let!(:app_path) { clone_js_npm_app }

    it 'detects the Javascript and NPM technology' do
      expect(technologies).to satisfy { |ts|
        ts.technology?(Technology.new(:js, :npm))
      }
    end
  end

  context 'with a Javascript YARN app' do
    let!(:app_path) { clone_js_yarn_app }

    it 'detects the Javascript and YARN technology' do
      expect(technologies).to satisfy { |ts|
        ts.technology?(Technology.new(:js, :yarn))
      }
    end
  end

  context 'with a Python Pip app' do
    let!(:app_path) { clone_py_app }

    it 'detects the Python and Pip technology' do
      expect(technologies).to satisfy { |ts|
        ts.technology?(Technology.new(:python, :pip))
      }
    end

    context 'with docker available' do
      it 'does not report any requirement warning' do
        allow(File).to receive(:socket?).with('/var/run/docker.sock') { true }
        expect(technologies.requirement_warnings.size).to eq(0)
      end
    end

    context 'with docker unavailable' do
      it 'warns user about outdated Gitlab CI configuration file' do
        allow(File).to receive(:socket?).with('/var/run/docker.sock') { false }
        expect(technologies.requirement_warnings[0]).to match(/To check your Python packages dependencies/)
      end
    end
  end

  context 'with a Java/Maven app' do
    let!(:app_path) { clone_maven_app }

    it 'detects the Java and Maven technology' do
      expect(technologies).to satisfy { |ts|
        ts.technology?(Technology.new(:java, :maven))
      }
    end

    context 'with docker available' do
      it 'does not report any requirement warning' do
        allow(File).to receive(:socket?).with('/var/run/docker.sock') { true }
        expect(technologies.requirement_warnings.size).to eq(0)
      end
    end

    context 'with docker unavailable' do
      it 'warns user about outdated Gitlab CI configuration file' do
        allow(File).to receive(:socket?).with('/var/run/docker.sock') { false }
        expect(technologies.requirement_warnings[0]).to match(/To check your Maven packages dependencies/)
      end
    end
  end
end
