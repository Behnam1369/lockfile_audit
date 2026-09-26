# frozen_string_literal: true

require_relative "lockfile_audit/version"
require_relative "lockfile_audit/errors"
require_relative "lockfile_audit/package_collector"
require_relative "lockfile_audit/vulnerability_collector"
require_relative "lockfile_audit/report"

# LockfileAudit parses a Gemfile.lock for resolved gems and reports
# vulnerabilities from bundler-audit as a single JSON-ready hash.
#
# @example
#   LockfileAudit.report(gemfile_lock_path: "Gemfile.lock")
#   # => {
#   #      generated_at: "2026-09-26T12:00:00Z",
#   #      packages: [{ name: "rails", version: "7.1.3" }, ...],
#   #      audit: { vulnerabilities: [{ gem: "nokogiri", ... }] }
#   #    }
module LockfileAudit
  # Builds the full report payload.
  #
  # @param gemfile_lock_path [String, Pathname] path to the Gemfile.lock file
  # @param audit_json [String, nil] pre-computed JSON from
  #   `bundle-audit check --format json`. When nil, bundler-audit is invoked
  #   directly.
  # @return [Hash] a JSON-ready hash matching the documented payload shape
  def self.report(gemfile_lock_path: "Gemfile.lock", audit_json: nil)
    Report.new(
      gemfile_lock_path: gemfile_lock_path,
      audit_json: audit_json
    ).call
  end
end
