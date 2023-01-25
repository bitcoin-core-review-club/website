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
commit: 3e8074faa3
---

## Notes

* [Bitcoin Inquisition](https://github.com/bitcoin-inquisition/bitcoin/wiki) is a fork of the Bitcoin Core codebase intended for testing consensus and relay policy changes. (Related mailing list posts: [[0]](https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020921.html) [[1]](https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020964.html) [[2]](https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021275.html)).
Bitcoin Inquisition nodes run on a
[signet](https://github.com/bitcoin/bips/blob/master/bip-0325.mediawiki)
test network (signet has been discussed in a previous [review club meeting](/18267)).

* Because the idea is to test consensus changes and we can expect them to potentially be buggy, we want the option to undo a consensus change when we find out it's buggy so that we can fix the bug. Adding this ability is a major departure from how consensus changes are handled on mainnet, where network coordination is required.

  * This [bitcoin-dev post](https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020242.html) by David Harding discusses automatically reverting soft forks on mainnet.

* This PR does a few things:

  - It [buries](https://github.com/bitcoin-core-review-club/bitcoin/commit/bf6972a1a838054a399d75111aeb27b387519434)
    the Taproot deployment, replacing the activation logic with hard-coded heights for
    its deployment status. We have discussed [deploymentstatus](/19438) and
    [burying deployments](/16060) in previous review club meetings.

  - It [replaces](https://github.com/bitcoin-core-review-club/bitcoin/commit/d3028d44d97629f821ea60c62515fd775a790f9b)
    [BIP 9](https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki) versionbits
    with [Heretical Deployments](https://github.com/bitcoin-inquisition/bitcoin/wiki/Heretical-Deployments),
designed to better suit the goal of testing consensus rules.

  - It [updates](https://github.com/bitcoin-core-review-club/bitcoin/commit/ea5901c64c090ac942c646174e8979a982800fc4)
    the getdeploymentinfo RPC to return activation and abandonment signals observed in blocks.

  - It [adds](https://github.com/bitcoin-core-review-club/bitcoin/commit/3e8074faa324b75b7c335d38ef0ebb38fca0164f)
    a `-renounce` config option to manually disable a Heretical Deployment.

* A comment in the PR includes [some notes about how the code is structured](https://github.com/bitcoin-inquisition/bitcoin/pull/16#pullrequestreview-1264958327). The previous version of the PR ([bitcoin-inquisition/bitcoin#2](https://github.com/bitcoin-inquisition/bitcoin/pull/2)), against Core/Inquisition version 23.0 is also available.

## Questions

1. Did you review the PR? [Concept ACK, approach ACK, tested ACK, or NACK](https://github.com/bitcoin/bitcoin/blob/master/CONTRIBUTING.md#peer-review)?

1. Why do we want to deploy consensus changes that aren't merged into Bitcoin Core? What problems (if any) are there with merging the code into Bitcoin Core, and then testing it on signet afterwards?

1. When have [ANYPREVOUT](https://github.com/bitcoin/bips/blob/master/bip-0118.mediawiki) and [CHECKTEMPLATEVERIFY](https://github.com/bitcoin/bips/blob/master/bip-0119.mediawiki) been activated on signet according to this logic? If we found a bug and needed to make
substantial changes, how would we do that? Would that result in a signet hard fork?

1. What is the point of the
   [DEACTIVATING](https://github.com/bitcoin-core-review-club/bitcoin/commit/d3028d44d97629f821ea60c62515fd775a790f9b#diff-73b381667b1bb315180fc7e7a66992e79ad742972de5d0d2c1b8404d3d67e1b0R30) state?

1. Why is `min_activation_height`
   [removed](https://github.com/bitcoin-core-review-club/bitcoin/commit/d3028d44d97629f821ea60c62515fd775a790f9b#diff-f5aa51ec54f17eba17214e33d06708d02f073dc9edaa271e05787b43d21a3b73L49-L53)?

1. Were you able to compile and run the code?

1. Were you able to test the code? What tests did you run?

1. Why is Taproot buried?

1.  What is the purpose of [`AbstractThresholdConditionChecker`](https://github.com/bitcoin/bitcoin/blob/50ac8f57748edd0bf4d42031710a59ebb8068a63/src/versionbits.h#L57)
and [`ThresholdConditionCache`](https://github.com/bitcoin/bitcoin/blob/50ac8f57748edd0bf4d42031710a59ebb8068a63/src/versionbits.h#L35-L38)
in `versionbits.h`?

1.  Could/should the [large commit](https://github.com/bitcoin-core-review-club/bitcoin/commit/d3028d44d97629f821ea60c62515fd775a790f9b)
be split up further? If so, how? If not, why not?

1.  Do any of the changes here make sense to include in Bitcoin Core?

<!-- TODO: After meeting, uncomment and add meeting log between the irc tags
## Meeting Log

{% irc %}
{% endirc %}
-->
