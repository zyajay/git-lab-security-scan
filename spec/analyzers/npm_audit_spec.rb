# frozen_string_literal: true

require_relative '../../lib/analyzers/npm_audit'
require 'spec_helper'

RSpec.describe Analyzers::NPMAudit do
  let(:app) { double(technologies: js_npm_techs, path: app_path) }

  context 'when running the NPM audit tool', :integration do
    let(:issues) do
      Bundler.with_clean_env do
        Analyzers::NPMAudit.new(app).execute
      end
    end

    let!(:app_path) { clone_js_npm_app }

    it 'expects to parse its output and find issues' do
      expect(issues.size).to be >= 2
      expect(issues).to all(have_attributes(tool: :npm_audit))
      expect(
        issues.any? { |i| i.message == "Prototype Pollution\n\nVersions of `deep-extend` before 0.5.1 are vulnerable to prototype pollution." }
      ).to be true
      expect(
        issues.any? { |i| i.cve.nil? || /\ACVE-/ =~ i.cve }
      ).to be true
      expect(
        issues.any? { |i| i.cve.nil? || /\ACWE-/ =~ i.cve }
      ).to be true
      expect(
        issues.none? { |i| i.cve.nil? }
      ).to be true
    end
  end

  context 'when processing a known NPM audit output file' do
    let!(:app_path) { file_fixture_path('empty_repository') }
    let(:issues) { mock_analyzer_output(Analyzers::NPMAudit.new(app), result_path) }

    context 'with output from a NPM app, and 1 vulnerability found' do
      let!(:result_path) { file_fixture_path('npm_audit_1_vuln.txt') }

      it 'expect to have correct issues' do
        expect(issues.size).to eq(1)
        expect(issues[0].tool).to eq(:npm_audit)
        expect(issues[0] .message).to eq("Regular Expression Denial of Service\n\nVersions of `hawk` prior to 3.1.3, or 4.x prior to 4.1.1 are affected by a regular expression denial of service vulnerability related to excessively long headers and URI's.")
      end
    end

    context 'NPM app, no vulnerabilities found' do
      let!(:result_path) { file_fixture_path('npm_audit_no_vuln.txt') }

      it 'handles empty output well' do
        expect(issues.size).to eq(0)
      end
    end
  end
end
