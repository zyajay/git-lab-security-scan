require_relative '../lib/issue'
require 'spec_helper'

RSpec.describe Issue do
  describe '#to_hash' do
    let(:issue) do
      issue = Issue.new
      issue.url = 'http://example.org'
      issue.message = 'Outdated dependency X'
      issue
    end

    it { expect(issue.to_hash.keys).to contain_exactly('url', 'message') }
    it { expect(issue.to_hash['url']).to eq('http://example.org') }
  end

  describe '#== and #eql?' do
    let(:issue1) do
      issue = Issue.new
      issue.tool = 'tool1'
      issue
    end

    let(:issue2) do
      issue = Issue.new
      issue.tool = 'tool2'
      issue
    end

    let(:issue3) do
      issue = Issue.new
      issue.tool = 'tool1'
      issue
    end

    it { expect(issue1).not_to eql(issue2) }
    it { expect(issue1).not_to be == issue2 }
    it { expect(issue1).to eql(issue3) }
    it { expect(issue1).to be == issue3 }
    it { expect([issue1, issue2, issue3].uniq.size).to be == 2 }
  end
end
