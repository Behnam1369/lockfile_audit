# frozen_string_literal: true

module LockfileAudit
  # Parses a Gemfile.lock and returns the resolved gem list.
  #
  # Only top-level specs from `specs:` blocks are collected. Transitive
  # dependency lines are skipped because they:
  #   - are indented further (6 spaces instead of 4), and
  #   - carry a version constraint (e.g. "= 7.1.3.2") rather than a
  #     resolved version.
  #
  # A Gemfile.lock may contain multiple specs blocks (e.g. PATH, GEM, GIT),
  # and all are collected.
  class PackageCollector
    # Matches a top-level spec line such as:
    #   "    rails (7.1.3)"
    # Exactly four leading spaces, then the gem name, then a version in
    # parentheses. The version itself must not start with a comparator
    # operator (=, <, >, ~), which would indicate a transitive dependency.
    SPEC_LINE = /\A {4}([^\s(]+) \(([^)=<>~!]+)\)\z/

    # Matches a "specs:" header line at any indentation depth.
    SPECS_HEADER = /\A\s*specs:\s*\z/

    # @param gemfile_lock_path [String, Pathname] path to the Gemfile.lock file
    def initialize(gemfile_lock_path:)
      @gemfile_lock_path = gemfile_lock_path
    end

    # @return [Array<Hash>] array of `{ name:, version: }` sorted by name
    # @raise [Errors::LockfileNotFound] if the lockfile does not exist
    def call
      unless File.exist?(@gemfile_lock_path)
        raise Errors::LockfileNotFound, @gemfile_lock_path
      end

      in_specs = false
      packages = []

      File.foreach(@gemfile_lock_path) do |raw_line|
        line = raw_line.chomp

        if line.match?(SPECS_HEADER)
          in_specs = true
          next
        end

        # A non-indented, non-empty line (e.g. "PLATFORMS" or "GEM")
        # ends the current specs block.
        in_specs = false if in_specs && !line.start_with?(" ")

        next unless in_specs

        match = line.match(SPEC_LINE)
        next unless match

        packages << {name: match[1], version: match[2]}
      end

      packages
        .uniq { |pkg| pkg[:name] }
        .sort_by { |pkg| pkg[:name] }
    end
  end
end
