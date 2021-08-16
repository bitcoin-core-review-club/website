---
layout: pr
date: 2021-08-18 
title: "Testing Bitcoin Core 22.0 Release Candidates"
components: ["tests"]
host: josibake
status: upcoming
---

## Notes

- Major versions of Bitcoin Core are released every 6-8 months. See the [Life
  Cycle documentation](https://bitcoincore.org/en/lifecycle/) for full details.

- When all of the PRs for a release have been merged, _Release Candidate 1_
  (rc1) is tagged. The rc is then tested. If any issues are found, fixes are
  merged into the branch and a new rc is tagged. This continues until no major
  issues are found in an rc, and that rc is then considered to be the final
  release version.

- To ensure that users don't experience issues with the new software, it's
  essential that the rcs are thoroughly tested. This special review club
  meeting is for people who want to help with that vital review process.

- This [Bitcoin Core Release Candidate Testing
  Guide](https://github.com/bitcoin-core/bitcoin-devwiki/wiki/22.0-Release-Candidate-Testing-Guide) has
  a tutorial for testing the release candidate.

  - **Please note**: for this release we will be testing new External Signer
    features, which will require you to either a) have a hardware wallet or b)
    setup a hardware wallet emulator.

  - If you plan to use an emulator, it is recommended you set it up before the
    meeting. You can follow the instructions for setting up the [Trezor
    emulator](https://docs.trezor.io/trezor-firmware/core/emulator/index.html) or
    the [Coldcard emulator](https://github.com/Coldcard/firmware).

- The guide is just to get you started on testing, so feel free to read the
  [Release
  Notes](https://github.com/bitcoin-core/bitcoin-devwiki/wiki/22.0-Release-Notes-draft)
  and bring ideas of other things you'd like to test!

<!-- TODO: After meeting, uncomment and add meeting log between the irc tags
## Meeting Log

{% irc %}
{% endirc %}
-->
