# frozen_string_literal: true

require_relative '../lib/report'
require_relative '../lib/issue'
require 'spec_helper'

RSpec.describe Report do
  describe '#dump' do
    let(:issues) do
      issues = [Issue.new, Issue.new, Issue.new]
      issues[0].priority = 'Low'
      issues[0].message = 'Low priority security issue'
      issues[1].priority = 'High'
      issues[1].message = 'High priority security issue'
      issues[2].priority = nil
      issues[2].message = 'Undefined priority security issue'

      Report.new(issues).dump
    end

    it { expect(JSON[issues][0]['priority']).to eq('High') }
  end

  describe '#dump with duplicates' do
    let(:issues) do
      issues = [Issue.new, Issue.new, Issue.new, Issue.new]
      issues[0].cve = '123'
      issues[0].tool = :gemnasium
      issues[0].message = 'Security issue from gemnasium'
      issues[1].priority = 'High'
      issues[1].cve = '123'
      issues[1].tool = :bundler_audit
      issues[1].message = 'High priority security issue from bundler audit'
      issues[2].priority = nil
      issues[2].tool = :bundler_audit
      issues[2].message = 'Undefined priority security issue from bundler audit'
      issues[3].cve = '123'
      issues[3].tool = :gemnasium
      issues[3].message = 'Another security issue from gemnasium with same CVE'

      Report.new(issues).dump
    end

    it 'expect to have deduped issues with same CVE' do
      dump = JSON[issues]
      expect(dump.size).to eq(3)
      expect(dump[0]['tool']).to eq('bundler_audit')
      expect(dump[0]['tools']).to eq(%w[bundler_audit gemnasium])
    end
  end

  describe '#output' do
    let(:issues) do
      issues = [Issue.new, Issue.new, Issue.new]
      issues[0].priority = 'Low'
      issues[0].message = 'Low priority security issue'
      issues[0].file = 'Gemfile.lock'
      issues[0].line = 23
      issues[1].priority = 'High'
      issues[1].message = 'High priority security issue'
      issues[1].file = 'Gemfile'
      issues[2].priority = 'Unknown'
      issues[1].message = 'Unknown priority security issue'
      issues
    end

    let(:report) { Report.new(issues) }

    it { expect { report.output }.to output.to_stdout }
    it { expect { report.output }.to output(/High/).to_stdout }
    it { expect { report.output }.to output(/Low priority security issue/).to_stdout }
    it { expect { report.output }.to output(/In Gemfile\.lock line 23/).to_stdout }
    it { expect { report.output }.to output(/In Gemfile/).to_stdout }
    it { expect { report.output }.to output(/3 security vulnerabilities/).to_stdout }
    it { expect { Report.new([Issue.new]).output }.to output(/1 security vulnerability/).to_stdout }
  end
end
