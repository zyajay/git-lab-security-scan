# frozen_string_literal: true

require_relative '../lib/run'
require 'rspec'

RSpec.describe Run do
  describe '#initialize' do
    let!(:app_path) { clone_py_no_vuln_app }
    let!(:app) { App.new(app_path) }
    let!(:analyze) { Analyze.new(app) }
    let!(:report) { Report.new([]) }

    before(:each) do
      allow(App).to receive(:new) { app }
      allow(Analyze).to receive(:new) { analyze }
      allow(analyze).to receive(:issues) { [] }
      allow(Report).to receive(:new) { report }
      allow(report).to receive(:save_as) {}
      allow(app).to receive_message_chain(:technologies, :requirement_warnings) { ['Warning1'] }
    end
  end
end
