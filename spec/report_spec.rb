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

  describe '#dump with duplicates sharing same CVE' do
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
      expect(dump.size).to eq(2)
      expect(dump[0]['tool']).to eq('bundler_audit')
      expect(dump[0]['tools']).to eq(%w[bundler_audit gemnasium])
      expect(dump[0]['message']).to eq('High priority security issue from bundler audit')
      expect(dump[0]['priority']).to eq('High')
      expect(dump[1]['tool']).to eq('bundler_audit')
      expect(dump[1]['message']).to eq('Undefined priority security issue from bundler audit')
      expect(dump[1]['priority']).to eq(nil)
    end
  end

  describe '#dump with duplicates sharing same message used as CVE' do
    let(:issues) do
      issues = [Issue.new, Issue.new, Issue.new, Issue.new]
      issues[0].cve = 'Prototype pollution attack for extend'
      issues[0].tool = :gemnasium
      issues[0].message = 'Prototype pollution attack for extend'
      issues[1].cve = 'Prototype pollution attack for extend'
      issues[1].tool = :retire
      issues[1].message = 'Prototype pollution attack for extend'
      issues[1].url = 'https://hackerone.com/reports/381185'
      issues[1].priority = 'Critical'
      issues[2].cve = 'Command Injection for macaddress'
      issues[2].tool = :retire
      issues[2].message = 'Command Injection for macaddress'
      issues[2].url = 'https://hackerone.com/reports/319467'
      issues[2].priority = 'High'
      issues[3].cve = 'Prototype pollution attack for extend'
      issues[3].tool = :retire
      issues[3].message = 'Prototype pollution attack for extend'

      Report.new(issues).dump
    end

    it 'expect to have deduped issues with same CVE' do
      dump = JSON[issues]
      expect(dump.size).to eq(2)
      expect(dump[0]['tool']).to eq('retire')
      expect(dump[0]['tools']).to eq(%w[retire gemnasium])
      expect(dump[0]['message']).to eq('Prototype pollution attack for extend')
      expect(dump[0]['url']).to eq('https://hackerone.com/reports/381185')
      expect(dump[0]['priority']).to eq('Critical')
      expect(dump[1]['tool']).to eq('retire')
      expect(dump[1]['message']).to eq('Command Injection for macaddress')
      expect(dump[1]['url']).to eq('https://hackerone.com/reports/319467')
      expect(dump[1]['priority']).to eq('High')
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
