# frozen_string_literal: true

require_relative '../lib/analyze'
require_relative '../lib/app'
require 'spec_helper'

RSpec.describe Analyze do
  context 'not supported language' do
    let!(:app_path) { file_fixture_path('empty_repository') }
    let(:app) { double(technologies: Technologies.new, path: app_path) }

    it 'expect to raise an error' do
      expect do
        Bundler.with_clean_env do
          allow_any_instance_of(Analyzers::Gemnasium).to receive(:found_technology?)
            .and_return(false)
          Analyze.new(app).issues
        end
      end.to raise_error(SystemExit)
    end
  end

  context 'repository with a Rails and YARN app containing vulnerabilities' do
    let!(:app_path) { clone_rails_yarn_app }
    let(:app) { App.new(app_path) }

    let(:issues) do
      Bundler.with_clean_env do
        allow_any_instance_of(Analyzers::Gemnasium).to receive(:found_technology?)
          .and_return(true)
        allow_any_instance_of(Analyzers::Gemnasium).to receive(:execute)
          .and_return([issue_for(:gemnasium)])
        allow_any_instance_of(Analyzers::Retire).to receive(:execute)
          .and_return([issue_for(:retire)])
        allow_any_instance_of(Analyzers::BundleAudit).to receive(:execute)
          .and_return([issue_for(:bundler_audit)])
        Analyze.new(app).issues
      end
    end

    it 'expect to have Gemnasium, Bundler Audit and Retire issues' do
      expect(issues.any? { |i| i.tool == :gemnasium }).to eq(true)
      expect(issues.any? { |i| i.tool == :retire }).to eq(true)
      expect(issues.any? { |i| i.tool == :bundler_audit }).to eq(true)
    end
  end

  context 'repository without vulnerabilities', :integration do
    let!(:app_path) { clone_py_no_vuln_app }
    let(:app) { App.new(app_path) }

    let(:issues) do
      Bundler.with_clean_env do
        allow_any_instance_of(Analyzers::Gemnasium).to receive(:found_technology?)
          .and_return(true)
        allow_any_instance_of(Analyzers::Gemnasium).to receive(:execute) do
          []
        end
        Analyze.new(app).issues
      end
    end

    it 'expect to have no issues' do
      expect(issues.size).to eq(0)
    end
  end

  context 'with remote checks disabled' do
    let!(:app_path) { file_fixture_path('empty_ruby_repository') }
    let(:app) { App.new(app_path) }
    let(:gms_analyzer) { double(found_technology?: false) }

    it 'expect to not exec Gemnasium analyzer' do
      Bundler.with_clean_env do
        allow_any_instance_of(Analyzers::BundleAudit).to receive(:execute)
          .and_return([])
        ENV['SAST_DISABLE_REMOTE_CHECKS'] = 'true'
        allow(Analyzers::Gemnasium).to receive(:new)
        allow(Analyzers::BundleAudit).to receive_message_chain(:new, :execute) { [] }
        Analyze.new(app).issues
        expect(Analyzers::Gemnasium).not_to have_received(:new)
      end
    end

    it 'expect to exec Gemnasium analyzer if another value than "true"' do
      Bundler.with_clean_env do
        ENV['SAST_DISABLE_REMOTE_CHECKS'] = ''
        allow(Analyzers::Gemnasium).to receive(:new).and_return(gms_analyzer)
        allow(Analyzers::BundleAudit).to receive_message_chain(:new, :execute) { [] }
        Analyze.new(app).issues
        expect(Analyzers::Gemnasium).to have_received(:new)
      end
    end
  end
end
