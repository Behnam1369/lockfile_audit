# frozen_string_literal: true

require "spec_helper"
require "pathname"

RSpec.describe LockfileAudit::Report do
  let(:fixtures_dir) { Pathname.new(__dir__).join("..", "fixtures") }
  let(:lockfile_path) { fixtures_dir.join("Gemfile.lock").to_s }
  let(:audit_json) { File.read(fixtures_dir.join("bundle_audit_array.json")) }

  subject(:report) do
    described_class.new(
      gemfile_lock_path: lockfile_path,
      audit_json: audit_json
    ).call
  end

  it "returns a Hash" do
    expect(report).to be_a(Hash)
  end

  it "includes a :generated_at timestamp" do
    expect(report).to have_key(:generated_at)
  end

  it "formats :generated_at as ISO8601 UTC with a trailing Z" do
    expect(report[:generated_at])
      .to match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\z/)
  end

  it "includes a :packages array" do
    expect(report[:packages]).to be_an(Array)
  end

  it "populates :packages from the lockfile" do
    names = report[:packages].map { |pkg| pkg[:name] }

    expect(names).to include("rails", "nokogiri", "pg")
  end

  it "includes an :audit hash" do
    expect(report[:audit]).to be_a(Hash)
  end

  it "includes :vulnerabilities inside :audit" do
    expect(report[:audit]).to have_key(:vulnerabilities)
  end

  it "populates :vulnerabilities from the audit JSON" do
    expect(report[:audit][:vulnerabilities].size).to eq(2)
  end

  it "matches the documented top-level payload shape" do
    expect(report.keys).to contain_exactly(:generated_at, :packages, :audit)
  end
end
