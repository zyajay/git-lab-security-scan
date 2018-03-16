require_relative '../lib/technology'
require 'rspec'

RSpec.describe Technology do
  describe '#language?' do
    let(:technology) { Technology.new(:ruby, :bundler, :rails) }

    it { expect(technology.language?(:ruby)).to be true }
    it { expect(technology.package_manager?(:bundler)).to be true }
    it { expect(technology.framework?(:rails)).to be true }
    it { expect(technology.framework?(:other)).to be false }
  end

  describe '#eql?' do
    let(:technology) { Technology.new(:ruby, :bundler, :rails) }
    let(:technology2) { Technology.new(:ruby, :bundler, :other) }
    let(:technology3) { Technology.new(:ruby, :bundler, :rails) }

    it { expect(technology).to eql(technology3) }
    it { expect(technology).not_to eql(technology2) }
  end
end
