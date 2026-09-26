# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2026-09-26

### Fixed

- `VulnerabilityCollector` now invokes `bundle-audit` using the same Ruby
  as the host application (`RbConfig.ruby`) and resolves the exact binary
  path via `Gem.bin_path`, instead of relying on `PATH`. This prevents
  `Bundler::RubyVersionMismatch` errors when the app's Ruby differs from
  the one on `PATH`.
- Added a missing `raise_not_installed` helper so the collector raises a
  clear `BundlerAuditNotInstalled` error (with stderr detail) instead of
  a `NoMethodError`.

## [0.1.0] - 2026-09-26

### Added

- `LockfileAudit.report` returns a JSON-ready Hash with `generated_at`,
  `packages` (from `Gemfile.lock`), and `audit.vulnerabilities`
  (from `bundler-audit`).
- `LockfileAudit::PackageCollector` parses every `specs:` block in a
  `Gemfile.lock`, collecting top-level gems with their resolved versions.
- `LockfileAudit::VulnerabilityCollector` normalizes `bundle-audit
  check --format json` output, tolerating both the Array and
  Hash-with-`results` schema shapes.
- `LockfileAudit::Report` assembles the final payload and stamps
  `generated_at` in ISO 8601 UTC.
- Support for passing pre-computed audit JSON via the `audit_json:`
  keyword, so `bundler-audit` need not be installed or invoked.
- `LockfileAudit::Errors` namespace with `LockfileNotFound`,
  `BundlerAuditNotInstalled`, and `InvalidAuditJson`.

[Unreleased]: https://github.com/Behnam1369/lockfile_audit/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/Behnam1369/lockfile_audit/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/Behnam1369/lockfile_audit/releases/tag/v0.1.0