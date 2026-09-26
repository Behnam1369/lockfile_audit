# frozen_string_literal: true

require "spec_helper"
require "pathname"

RSpec.describe LockfileAudit::PackageCollector do
  let(:fixture_path) do
    Pathname.new(__dir__).join("..", "fixtures", "Gemfile.lock").to_s
  end

  describe "#call" do
    subject(:packages) do
      described_class.new(gemfile_lock_path: fixture_path).call
    end

    it "returns every top-level gem from every specs block" do
      names = packages.map { |pkg| pkg[:name] }

      expect(names).to include(
        "lockfile_audit", "nokogiri", "pg", "racc",
        "rails", "actionpack", "activesupport", "rack"
      )
    end

    it "returns each package with :name and :version keys" do
      packages.each do |pkg|
        expect(pkg).to have_key(:name)
        expect(pkg).to have_key(:version)
      end
    end

    it "sorts packages by name" do
      names = packages.map { |pkg| pkg[:name] }

      expect(names).to eq(names.sort)
    end

    it "deduplicates packages that appear more than once" do
      names = packages.map { |pkg| pkg[:name] }

      expect(names).to eq(names.uniq)
    end

    it "extracts the correct version for a top-level spec" do
      rails = packages.find { |pkg| pkg[:name] == "rails" }

      expect(rails[:version]).to eq("7.1.3")
    end

    it "ignores transitive dependency lines that carry a comparator version" do
      # "actionpack (= 7.1.3)" appears as a transitive dep of rails,
      # but the top-level actionpack spec has the plain version.
      actionpack = packages.find { |pkg| pkg[:name] == "actionpack" }

      expect(actionpack[:version]).to eq("7.1.3")
    end

    it "does not include any version starting with a comparator operator" do
      comparator_versions = packages.select do |pkg|
        pkg[:version].start_with?("=", "<", ">", "~", "!")
      end

      expect(comparator_versions).to be_empty
    end

    context "when the lockfile does not exist" do
      subject(:call_with_missing_file) do
        described_class.new(gemfile_lock_path: "/nonexistent/Gemfile.lock").call
      end

      it "raises LockfileNotFound" do
        expect { call_with_missing_file }
          .to raise_error(LockfileAudit::Errors::LockfileNotFound, /Gemfile.lock not found/)
      end
    end

    context "with a Windows-style line ending" do
      let(:crlf_path) do
        file = Tempfile.new(["Gemfile", ".lock"])
        file.write(File.read(fixture_path).gsub("\n", "\r\n"))
        file.close
        file.path
      end

      it "still parses packages correctly" do
        result = described_class.new(gemfile_lock_path: crlf_path).call
        names = result.map { |pkg| pkg[:name] }

        expect(names).to include("rails", "nokogiri", "pg")
      end
    end
  end
end
