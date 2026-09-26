# frozen_string_literal: true

require "time"

module LockfileAudit
  # Assembles the final payload by combining packages and vulnerabilities.
  class Report
    # @param gemfile_lock_path [String, Pathname] path to the Gemfile.lock file
    # @param audit_json [String, nil] pre-computed bundler-audit JSON; if nil,
    #   bundler-audit is invoked directly
    def initialize(gemfile_lock_path: "Gemfile.lock", audit_json: nil)
      @gemfile_lock_path = gemfile_lock_path
      @audit_json = audit_json
    end

    # @return [Hash] payload with `:generated_at`, `:packages`, and `:audit`
    def call
      {
        generated_at: Time.now.utc.iso8601,
        packages: packages,
        audit: {
          vulnerabilities: vulnerabilities
        }
      }
    end

    private

    def packages
      PackageCollector.new(gemfile_lock_path: @gemfile_lock_path).call
    end

    def vulnerabilities
      VulnerabilityCollector.new(
        audit_json: @audit_json,
        lockfile_path: @gemfile_lock_path
      ).call
    end
  end
end
