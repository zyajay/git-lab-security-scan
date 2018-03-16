require_relative '../../lib/analyzers/gemnasium'
require 'spec_helper'

RSpec.describe Analyzers::Gemnasium do
  let(:app) { double(technologies: js_yarn_techs, path: app_path) }

  context 'when running the Gemnasium tool on a JS Yarn repository', :integration do
    let(:analyzer) { Analyzers::Gemnasium.new(app) }
    let(:issues) { Bundler.with_clean_env { analyzer.execute } }
    let(:found_technologies) { analyzer.found_technology? }

    let!(:app_path) { clone_js_yarn_app }

    it 'expects to report finding handled technologies' do
      expect(found_technologies).to be true
    end

    it 'expects to parse its output and find issues' do
      expect(issues.size).to be >= 1
      expect(issues).to all(have_attributes(tool: :gemnasium))
      expect(issues.any? { |i| i.message == 'Regular Expression Denial of Service for minimatch' }).to be true
    end
  end

  context 'when running the Gemnasium tool on an empty repository', :integration do
    let(:analyzer) { Analyzers::Gemnasium.new(app) }
    let(:issues) { Bundler.with_clean_env { analyzer.execute } }
    let(:found_technologies) { analyzer.found_technology? }

    let!(:app_path) { file_fixture_path('empty_repository') }

    it 'expects to report finding no handled technology' do
      expect(found_technologies).to be false
    end

    it 'expects to not return any issue' do
      expect(issues.size).to eq(0)
    end
  end

  context 'when processing a known Gemnasium output file' do
    let!(:app_path) { file_fixture_path('empty_repository') }
    let!(:result_path) { file_fixture_path('gemnasium_output.json') }
    let(:issues) { mock_analyzer_output(Analyzers::Gemnasium.new(app), result_path) }

    it 'expect to have correct issues' do
      expect(issues.size).to eq(9)
      expect(issues).to all(have_attributes(tool: :gemnasium))
      expect(issues[0].message).to eq('Regular Expression Denial of Service for minimatch')
    end
  end
end
