# omarchy-m-testing

Check Apple Silicon Mac hardware under Linux and share results at
[omarchy-m-testing.org](https://omarchy-m-testing.org).

The `omarchy-m-test` CLI checks boot setup, drivers, displays, audio,
networking, power and other hardware. It also asks you to try features such
as brightness keys or a camera frame. The feature catalogue explains each
result: working, unsupported, unknown, or not present on that model.

## Requirements

- An Apple Silicon Mac running Linux. Some checks need Omarchy or Arch tools.
- `curl`, `tar`, `gzip`, `python3` and OpenSSH's `ssh-keygen`.
- A person at the Mac for local-seat checks. SSH skips disruptive checks,
  but other checks and some questions still run.
- Passwordless sudo for checks that use `sudo -n`. Without it, those checks
  are skipped. Password prompts can still occur for test packages, the
  charge limit, Wi-Fi driver reloads and privileged cleanup.

The tool never reboots the Mac or touches disk encryption or boot files.
It attempts to restore changes. If restoration fails, it prints a command
you can run by hand.

## Install

Run this on the Mac:

```sh
curl -fsSL https://omarchy-m-testing.org/install | bash
```

The installer checks a signed release and installs it under
`~/.local/share/omarchy-m-test`, with a link in `~/.local/bin`. Run the same
command again to upgrade. The CLI checks for newer releases before a run.

## Run

```sh
omarchy-m-test
```

Follow the prompts. Skipping a check is not a failure. The CLI writes a
report and shows it before asking whether to upload it. Upload is opt-in.

Useful commands:

```sh
omarchy-m-test --dry-run       # checks and local report, but no upload
omarchy-m-test --output FILE   # choose the local report path
omarchy-m-test --explain REPORT
omarchy-m-test --sign-in
omarchy-m-test --status
omarchy-m-test --sign-out
```

`--dry-run` does not mean read-only: checks still run and local files are
written. `--explain` reads a saved report without running hardware checks.
`--site URL` selects a different upload site.

On first use, the CLI creates a machine signing key under
`~/.local/state/omarchy-m-test/`. The site checks report signatures. GitHub
sign-in binds your handle to that key; an allowlisted handle's reports
count as tester runs.

## Privacy

Reports never carry serial numbers, MAC addresses, hostnames, usernames,
Wi-Fi network names, IP addresses, disk identifiers, key slots or
home-directory content. Audio and camera frames are measured on the Mac,
not kept in reports. Each upload gets a deletion link.

## Read the results

- Expected support gaps appear as `GAP`, not `FAIL`. Missing hardware
  appears as `N/A`.
- A skipped check gives its reason. Some need a local desktop, an external
  device or a service such as speakersafetyd.
- Community matrix cells need agreement from at least two distinct machines.
  Tester reports follow the site's separate verification rules.

## Verify a release by hand

The release key is pinned in `installer/install.sh` and
[`release/allowed_signers`](release/allowed_signers):

```text
release@omarchy-m-testing.org namespaces="omarchy-m-test-release" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHA9ywzf4hxAd5Ohzw8tRg5i2lxHAxp2mDV0PWi5o0u
```

With the release archive and its signature downloaded:

```sh
ssh-keygen -Y verify -f release/allowed_signers -I release@omarchy-m-testing.org \
  -n omarchy-m-test-release -s omarchy-m-test.tar.gz.sig < omarchy-m-test.tar.gz
```

## Documentation

- [CLI guide](cli/README.md): checks, recording and tester sign-in.
- [Feature catalogue](catalogue/README.md): Asahi, Aurora and Omarchy support layers.
- [Site guide](site/README.md): pages, API, exports and administration.
- [Report schema](schema/report-v1.schema.json): the versioned report format.
- [Release tools](release/): build and signing setup.

Report bugs and feature requests in this repository's GitHub issues.
