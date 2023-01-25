---
layout: pr
date: 2023-02-08
title: "bitcoin-inquisition #16: Activation logic for testing consensus changes"
link: https://github.com/bitcoin-inquisition/bitcoin/pull/16
permalink: /bitcoin-inquisition-16
authors: [ajtowns]
components: [consensus]
host: ajtowns
status: upcoming
commit:
---

## Notes

* [Bitcoin Inquisition](https://github.com/bitcoin-inquisition/bitcoin/wiki) is a fork of the Bitcoin Core codebase intended for testing consensus and relay policy changes. (Related mailing list posts: [[0]](https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020921.html) [[1]](https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020964.html) [[2]](https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021275.html)

* Because the idea is to test consensus changes, we can expect them to potentially be buggy, and will thus want the option to undo a consensus change when we find out it's buggy so that we can fix the bug, which is a major departure from how consensus changes are handled on mainnet.
  * [bitcoin-dev post](https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020242.html) by David Harding on automatically reverting soft forks on mainnet.

* Thus, this PR replaces [BIP 9](https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki) versionbits with [Heretical Deployments](https://github.com/bitcoin-inquisition/bitcoin/wiki/Heretical-Deployments), designed to better meet that goal.

* A comment in the PR includes [some notes about how the code is structured](https://github.com/bitcoin-inquisition/bitcoin/pull/16#pullrequestreview-1264958327). The previous version of the PR ([inquisition#2](https://github.com/bitcoin-inquisition/bitcoin/pull/16)), against Core/Inquisition version 23.0 is also available.

* Related review clubs:
  * [deployment status #19438 2021-03-24](https://bitcoincore.reviews/19438)
  * [signet #18267 2020-09-09](https://bitcoincore.reviews/18267)

## Questions
1. Did you review the PR? [Concept ACK, approach ACK, tested ACK, or NACK](https://github.com/bitcoin/bitcoin/blob/master/CONTRIBUTING.md#peer-review)?

2. Why do we want to deploy consensus changes that aren't merged into Bitcoin Core? What problems (if any) are there with merging the code into Bitcoin Core, and then testing it on signet afterwards?

3. ANYPREVOUT and CHECKTEMPLATEVERIFY have already been activated on signet according to this logic (when?). If we found a bug and needed to make
substantial changes, how would we do that? Would that result in a signet hard fork?

5. What is the point of the DEACTIVATING state?

6. Why is `min_activation_height` removed?

7. Were you able to compile and run the code?

8. Were you able to test the code? What tests did you run?

9. Why is Taproot buried?

10. What is the purpose of `AbstractThresholdConditionChecker` and `ThresholdConditionCache` in versionbits.h?

11. Could/should the large commit be split up further? If so, how? If not,
why not?

12. Do any of the changes here make sense to include in Bitcoin Core?

<!-- TODO: After meeting, uncomment and add meeting log between the irc tags
## Meeting Log

{% irc %}
{% endirc %}
-->
