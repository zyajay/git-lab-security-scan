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
      expect(issues.any? { |i| i.message == 'Regular Expression Denial of Service in debug' }).to be true
      expect(issues.any? { |i| i.solution == 'Upgrade to latest versions.' }).to be true
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
    let!(:result_path) { file_fixture_path('gl-dependency-scanning-report.json') }
    let(:issues) { mock_analyzer_output(Analyzers::Gemnasium.new(app), result_path) }

    it 'expect to have correct issues' do
      expect(issues.size).to eq(9)
      expect(issues).to all(have_attributes(tool: :gemnasium))
      expect(issues).to all(have_attributes(priority: "Unknown"))

      expect(issues[0].url).to be_nil
      expect(issues[0].file).to eq('Gemfile.lock')
      expect(issues[0].message).to eq('Vulnerabilities in libxml2 in nokogiri')
      expect(issues[0].solution).to eq('Upgrade to latest version.')
      expect(issues[0].cve).to eq('Vulnerabilities in libxml2 in nokogiri')

      expect(issues[1].url).to eq("https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-11068")
      expect(issues[1].file).to eq('Gemfile.lock')
      expect(issues[1].message).to eq('Bypass of a protection mechanism in libxslt in nokogiri')
      expect(issues[1].solution).to eq('Upgrade to latest version if using vendored version of libxslt OR update the system library libxslt to a fixed version')
      expect(issues[1].cve).to eq('CVE-2019-11068')
    end
  end
end
