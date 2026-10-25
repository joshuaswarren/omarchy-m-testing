# omarchy-m-testing

Test every hardware feature of your Apple Silicon Mac under Omarchy, and share the results at [omarchy-m-testing.org](https://omarchy-m-testing.org).

## What it is

`omarchy-m-test` runs automatic checks (boot chain, encryption, GPU driver and Vulkan/OpenGL, displays, audio and speaker protection, Wi-Fi, Bluetooth, snapshots, battery and charge limit, CPU frequency scaling, camera, ports, Touch ID) and asks a few questions you answer by looking, listening or trying something (brightness keys, trackpad, lid sleep, a live camera frame). Every result is explained against a versioned [feature catalogue](catalogue/README.md): works, not yet supported by Aurora, not yet supported by Asahi, unknown hardware, and so on. Upload is opt-in; reports are shown at [omarchy-m-testing.org](https://omarchy-m-testing.org) so gaps and regressions are visible per model.

## Requirements

- An Apple Silicon (M-series) Mac running Omarchy or another Linux on the Apple platform.
- `curl`, `tar`, `python3` and `ssh-keygen` (OpenSSH) — all on a stock Omarchy install.
- A person at the Mac for the interactive checks; over SSH those are skipped, never failed.
- Passwordless `sudo` for the checks that need it (they run through `sudo -n`); without it those checks are skipped. The tool asks for a password only to install temporary test packages (removed afterwards) and to set the battery charge limit.

The tool never reboots the Mac, never touches disk encryption or boot files, and restores every change it makes.

## Install

On the Mac:

    curl -fsSL https://omarchy-m-testing.org/install | bash

The installer downloads the latest tagged release, checks its signature and installs `omarchy-m-test` under `~/.local/share/omarchy-m-test`, linked from `~/.local/bin`. Run it again to upgrade. The tool tells you before each run when a newer release exists.

Releases are signed with this key (`release/allowed_signers`, also pinned in `installer/install.sh`):

    release@omarchy-m-testing.org namespaces="omarchy-m-test-release" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHA9ywzf4hxAd5Ohzw8tRg5i2lxHAxp2mDV0PWi5o0u

To check a download by hand:

    ssh-keygen -Y verify -f release/allowed_signers -I release@omarchy-m-testing.org \
      -n omarchy-m-test-release -s omarchy-m-test.tar.gz.sig < omarchy-m-test.tar.gz

## Use

Run it and follow the prompts:

    omarchy-m-test

Useful flags:

    omarchy-m-test --dry-run                 # run without writing a report
    omarchy-m-test --output FILE             # write the report somewhere specific
    omarchy-m-test --site URL                # upload to a different site (e.g. http://localhost:3000)
    omarchy-m-test --explain REPORT          # re-explain a saved report against the current catalogue
    omarchy-m-test --sign-in | --status | --sign-out   # GitHub sign-in so your runs count as tester runs

On its first run the CLI creates an ed25519 key for the Mac (in `~/.local/state/omarchy-m-test/`) and signs every report with it; the site refuses unsigned or tampered reports. With `--sign-in`, a GitHub device-flow sign-in binds your handle to that key so your runs are counted as tester runs.

**Privacy.** Reports never carry serial numbers, MAC addresses, hostnames, usernames, Wi-Fi network names, IP addresses, disk identifiers or home-directory content; microphone and camera measurements are computed on the Mac and the audio or frames are never kept. Every upload gets a deletion link.

## Limits

- Failures the catalogue expects on your Mac show as `GAP` (not yet supported by Asahi, Aurora or Omarchy) or `N/A` (no such hardware) rather than `FAIL`.
- Some checks need specific conditions (a local seat for lid sleep, external displays for the display checks, speakersafetyd active before any test tone); they are skipped with the reason.
- The site's matrix colours a cell only when two or more distinct machines agree; a single community run stays unconfirmed.

## Docs

- [`cli/`](cli/README.md) — every check, flag, the machine key, tester sign-in, recording a Mac.
- [`catalogue/`](catalogue/README.md) — the feature catalogue and its Asahi/Aurora/Omarchy layers.
- [`site/`](site/README.md) — the site, its pages, API, exports and admin.
- [`schema/`](schema/report-v1.schema.json) — the versioned report schema and golden reports.
- Issues and roadmap live in this repository's GitHub issues.

## Layout

- `cli/`: the `omarchy-m-test` command.
- `site/`: the omarchy-m-testing.org site and API.
- `schema/`: the versioned report schema and the golden reports both are tested against.
- `installer/`: the one-line installer the site serves at `/install`, and its test.
- `release/`: the release build and the release signing public key.
- `catalogue/`: the versioned feature catalogue every result is explained against, and the tool that keeps its Asahi layer in step with Asahi's feature tables.
