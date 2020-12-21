---
layout: pr
date: 2020-12-23
title: "Testing Bitcoin Core 0.21 Release Candidates"
components: ["tests"]
host: jarolrod
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
  Guide](https://gist.github.com/jarolrod/6495932dc6b598ddef49e6374b348f4e) has
  a tutorial for testing the release candidate.

<!--

## Meeting Log

{% irc %}
{% endirc %}

-->
