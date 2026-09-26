# LockfileAudit

Returns a JSON package inventory plus vulnerability audit data for a Ruby
project, in a single payload.

`lockfile_audit` parses a `Gemfile.lock` for the resolved gem list and pairs it
with findings from [bundler-audit](https://github.com/rubysec/bundler-audit).
The result is a plain, JSON-ready Hash you can expose from a Rails endpoint,
feed into a dashboard, or archive for compliance.

## Installation

Add it to your Gemfile:

    gem "lockfile_audit"

Then run `bundle install`.

To collect vulnerability data, `bundler-audit` must be available on your
PATH:

    gem install bundler-audit
    bundle-audit update   # fetch the advisory database

If you would rather manage that step yourself, you can pass pre-computed
audit JSON instead — see Usage.

## Usage

### Basic

    require "lockfile_audit"

    LockfileAudit.report(gemfile_lock_path: "Gemfile.lock")

This returns:

    {
      "generated_at": "2026-09-26T11:09:28Z",
      "packages": [
        { "name": "rails", "version": "7.1.3" },
        { "name": "nokogiri", "version": "1.16.2" },
        { "name": "pg", "version": "1.5.6" }
      ],
      "audit": {
        "vulnerabilities": [
          {
            "gem": "nokogiri",
            "version": "1.16.2",
            "criticality": "High",
            "description": "Nokogiri Command Injection Vulnerability"
          }
        ]
      }
    }

### Passing pre-computed audit JSON

If you already run `bundle-audit` in your own CI pipeline, or want to avoid
shelling out at request time, pass its JSON output directly:

    audit_json = File.read("tmp/bundle-audit.json")

    LockfileAudit.report(
      gemfile_lock_path: "Gemfile.lock",
      audit_json: audit_json
    )

When `audit_json:` is provided, `lockfile_audit` does not invoke
`bundler-audit` at all.

### From a Rails controller

    class PackageAuditController < ApplicationController
      def show
        render json: LockfileAudit.report(
          gemfile_lock_path: Rails.root.join("Gemfile.lock").to_s
        )
      end
    end

## Payload schema

| Key | Type | Notes |
|-----|------|-------|
| `generated_at` | String | ISO 8601 UTC timestamp, e.g. `"2026-09-26T11:09:28Z"` |
| `packages` | Array | Sorted by `name`; each entry has `name` and `version` |
| `audit` | Hash | Contains a single `vulnerabilities` key |
| `audit.vulnerabilities` | Array | Each entry has `gem`, `version`, `criticality`, and `description` |

All keys are symbols when you consume the Hash in Ruby, and strings when
serialized to JSON. `description` falls back to the advisory title when no
longer description is available.

## Errors

All errors inherit from `LockfileAudit::Errors::Error`.

| Error | Raised when |
|-------|-------------|
| `LockfileNotFound` | The `Gemfile.lock` file does not exist at the given path |
| `BundlerAuditNotInstalled` | `bundle-audit` is not on `PATH` and no `audit_json:` was passed |
| `InvalidAuditJson` | The supplied audit JSON cannot be parsed |

## How it works

- Packages are read from the `specs:` blocks of `Gemfile.lock`. Only
  top-level specs are collected; transitive dependency lines (which carry a
  version constraint rather than a resolved version) are ignored.
- Vulnerabilities come from `bundle-audit check --format json`. The output
  is normalized to tolerate both known schema shapes: a bare Array of
  findings, or a Hash with a `results` key.
- The `bundle-audit` subprocess runs with a scrubbed environment, so the
  parent process's Bundler state (`BUNDLE_*`, `RUBYOPT`) does not leak into
  it. This makes the collector safe to call from inside a running Rails app.

## Development

    bundle install
    bundle exec rspec
    bundle exec standardrb

To release a new version:

1. Bump `lib/lockfile_audit/version.rb`.
2. Update `CHANGELOG.md`.
3. `gem build lockfile_audit.gemspec`
4. `gem push lockfile_audit-<version>.gem`

## License

MIT. See LICENSE.txt.