# frozen_string_literal: true

module LockfileAudit
  # Namespace for all errors raised by LockfileAudit.
  module Errors
    # Base class for every LockfileAudit error.
    class Error < StandardError; end

    # Raised when the Gemfile.lock file does not exist at the given path.
    class LockfileNotFound < Error
      def initialize(path)
        super("Gemfile.lock not found at: #{path}")
      end
    end

    # Raised when the `bundle-audit` executable cannot be found on PATH.
    class BundlerAuditNotInstalled < Error
      def initialize(message = nil)
        super(message || "bundler-audit is not installed or not on PATH")
      end
    end

    # Raised when `bundle-audit` runs but exits with a non-zero status
    # other than 1 (which conventionally means "vulnerabilities found").
    class BundlerAuditFailed < Error; end

    # Raised when the supplied audit JSON cannot be parsed.
    class InvalidAuditJson < Error
      def initialize(message = nil)
        super("Could not parse bundler-audit JSON: #{message}")
      end
    end
  end
end
