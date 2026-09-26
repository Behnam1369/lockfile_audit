# frozen_string_literal: true

require "spec_helper"
require "pathname"

RSpec.describe LockfileAudit do
  it "has a version number" do
    expect(LockfileAudit::VERSION).not_to be_nil
  end

  describe ".report" do
    let(:fixtures_dir) { Pathname.new(__dir__).join("fixtures") }
    let(:lockfile_path) { fixtures_dir.join("Gemfile.lock").to_s }
    let(:audit_json) { File.read(fixtures_dir.join("bundle_audit_array.json")) }

    it "returns the full payload" do
      report = LockfileAudit.report(
        gemfile_lock_path: lockfile_path,
        audit_json: audit_json
      )

      expect(report).to include(:generated_at, :packages, :audit)
      expect(report[:packages]).not_to be_empty
      expect(report[:audit][:vulnerabilities]).not_to be_empty
    end
  end
end
