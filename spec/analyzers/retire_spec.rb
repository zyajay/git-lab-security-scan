require_relative '../../lib/analyzers/retire'
require 'spec_helper'

RSpec.describe Analyzers::Retire do
  let(:app) { double(technologies: js_npm_techs, path: app_path) }

  context 'when running the Retire tool', :integration do
    let(:issues) do
      Bundler.with_clean_env do
        Analyzers::Retire.new(app).execute
      end
    end

    let!(:app_path) { clone_js_npm_app }

    it 'expects to parse its output and find issues' do
      expect(issues.size).to be >= 1
      expect(issues).to all(have_attributes(tool: :retire))
      expect(issues.any? { |i| i.url == 'https://nodesecurity.io/advisories/51' }).to be true
    end
  end

  context 'when processing a known Retire output file' do
    let!(:app_path) { file_fixture_path('empty_repository') }
    let!(:result_path) { file_fixture_path('retire_output.json') }
    let(:issues) { mock_analyzer_output(Analyzers::Retire.new(app), result_path) }

    it 'expect to have correct issues' do
      expect(issues.size).to eq(5)
      expect(issues[0].priority).to eq('Medium')
      expect(issues[0].cve).to eq('CVE-2015-2951')
      expect(issues[0].message).to eq('3rd party CORS request may execute for jquery')
      expect(issues[0].tool).to eq(:retire)
      expect(issues[0].url).to eq('https://github.com/jquery/jquery/issues/2432')

      expect(issues[2].priority).to eq('High')
      expect(issues[2].cve).to eq('Vulnerability for ansi2html')
      expect(issues[2].message).to eq('Vulnerability for ansi2html')
      expect(issues[2].tool).to eq(:retire)
      expect(issues[2].url).to eq('https://nodesecurity.io/advisories/51')
    end
  end
end
