require_relative '../../lib/analyzers/bundle_audit'
require 'spec_helper'

RSpec.describe Analyzers::BundleAudit do
  let(:app) { double(technologies: rails_techs, path: app_path) }

  context 'when running the Bundle audit tool', :integration do
    let(:issues) do
      Bundler.with_clean_env do
        Analyzers::BundleAudit.new(app).execute
      end
    end

    let!(:app_path) { clone_rails_app }

    it 'expects to parse its output and find issues' do
      expect(issues.size).to be >= 2
      expect(issues).to all(have_attributes(tool: :bundler_audit))
      expect(
        issues.any? { |i| i.message == 'uglifier incorrectly handles non-boolean comparisons during minification' }
      ).to be true
    end
  end

  context 'when processing a known Bundle audit output file' do
    let!(:app_path) { file_fixture_path('empty_repository') }
    let(:issues) { mock_analyzer_output(Analyzers::BundleAudit.new(app), result_path) }

    context 'with output from a rails app, and 1 vulnerability found' do
      let!(:result_path) { file_fixture_path('bundle_audit_rails_1_vuln.txt') }

      it 'expect to have correct issues' do
        expect(issues.size).to eq(1)
        expect(issues[0].tool).to eq(:bundler_audit)
        expect(issues[0] .message).to eq('Nokogiri gem, via libxml, is affected by DoS vulnerabilities')
      end
    end

    context 'ruby app, no vulnerabilities found' do
      let!(:result_path) { file_fixture_path('bundle_audit_ruby_no_vuln.txt') }

      it 'handles empty output well' do
        expect(issues.size).to eq(0)
      end
    end
  end
end
