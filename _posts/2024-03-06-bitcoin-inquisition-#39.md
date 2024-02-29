---
layout: pr
date: 2024-03-06
title: "bitcoin-inquisition #39: Re enable OP_CAT"
link: https://github.com/bitcoin-inquisition/bitcoin/pull/39
permalink: /bitcoin-inquisition-39
authors: ["0xBEEFCAF3", EthanHeilman]
components: ["consensus"]
host: EthanHeilman
status: upcoming
commit:
---

## Notes

The following pull request (PR) reinstates the usage of OP_CAT in accordance with the specifications outlined in the draft BIP, which can be found [here](https://github.com/bitcoin/bips/pull/1525). Reviewers are encouraged to familiarize themselves with the BIP before examining the code.

- The primary objective of this PR is to re-enable OP_CAT utilizing OP_SUCCESS semantics, replacing OP_SUCCESS126.
  - OP_CAT is designed to concatenate two elements on the stack.
  - If the resulting element is smaller than the [`MAX_SCRIPT_ELEMENT_SIZE`](https://github.com/0xBEEFCAF3/bitcoin/blob/armin/re-enable-op-cat/src/script/script.h#L24), it is placed on the stack.
- OP_CAT should fail if there are less than two values on the stack or if a concatenated value would have a combined size greater than [`MAX_SCRIPT_ELEMENT_SIZE`](https://github.com/0xBEEFCAF3/bitcoin/blob/armin/re-enable-op-cat/src/script/script.h#L24).
- The PR also introduces activation parameters for the Bitcoin Signet network, aligning with the [BIN-2024-0002](https://github.com/bitcoin-inquisition/binana/blob/master/2024/BIN-2024-0002.md) standard.
- Additionally, this PR introduces new semantics for testing taproot-related script tests.

#### Motivation for OP_CAT
OP_CAT aims to expand the toolbox of the tapscript developer with a simple, modular, and useful opcode in the [spirit of Unix](https://harmful.cat-v.org/cat-v/unix_prog_design.pdf). To demonstrate the usefulness of OP_CAT below we provide a non-exhaustive list of some usecases that OP_CAT would enable:

* [Bitstream](https://robinlinus.com/bitstream.pdf), a protocol for the atomic swap (fair exchange) of bitcoins for decryption keys, that enables decentralized file hosting systems paid in Bitcoin. While such swaps are currently possible on Bitcoin without OP_CAT they require the use of complex and computationally expensive Verifiable Computation cryptographic techniques. OP_CAT would remove this requirement on Verifiable Computation, making such protocols far more practical to build in Bitcoin.
* [Vaults](http://fc16.ifca.ai/bitcoin/papers/MES16.pdf) which are a specialized covenant that allows a user to block a malicious party who has compromised the user's secret key from stealing the funds in that output. The first CAT vault has been developed by Rijndael. Find more details on CAT vaults in practice [here](https://delvingbitcoin.org/t/basic-vault-prototype-using-op-cat/576)
* [Replicating CheckSigFromStack](https://medium.com/blockstream/cat-and-schnorr-tricks-i-faf1b59bd298) which would allow the creation of simple covenants and other advanced contracts without having to presign spending transactions, possibly reducing complexity and the amount of data that needs to be stored. Originally shown to work with Schnorr signatures, [this result has been extended to ECDSA signatures](https://gist.github.com/RobinLinus/9a69f5552be94d13170ec79bf34d5e85#file-covenants_cat_ecdsa-md).
For more usecases please checkout the [BIP](https://github.com/bitcoin/bips/pull/1525)


## Questions

1. Did you review the PR? [Concept ACK, approach ACK, tested ACK, or NACK](https://github.com/bitcoin/bitcoin/blob/master/CONTRIBUTING.md#peer-review)? What was your review approach?

1. OP_CAT is defined as 0x7e. Even after replacing an OP_SUCCESS opcode, libraries can continue to use 0x7e to represent concatenation operations. Why is this the case?

1. A new script verify flag is introduced: [`SCRIPT_VERIFY_OP_CAT`](https://github.com/0xBEEFCAF3/bitcoin/blob/armin/re-enable-op-cat/src/script/interpreter.h#L162). Is this considered a consensus-validating flag or a policy?

1. If it is policy, where does the mempool policy reject transactions that use OP_CAT? Why does this policy exist?

1. In [`deploymentinfo.cpp`](https://github.com/0xBEEFCAF3/bitcoin/blob/armin/re-enable-op-cat/src/deploymentinfo.cpp#L96), there are both an `OP_CAT` flag and a `DISCOURAGE_OP_CAT` flag. What is the rationale behind having both of these?

1. When does consensus consider OP_SUCCESS126 replaced by OP_CAT?

1. Why is it important to verify if OP_CAT is being executed in a non-segwitv0 or base-script context at [`L474:interpreter.cpp`](https://github.com/0xBEEFCAF3/bitcoin/blob/armin/re-enable-op-cat/src/script/interpreter.cpp#L475) rather than inside the opcode definition?

1. This PR introduces new semantics for taproot-related script tests in `script_tests.json`. For example, [this test](https://github.com/0xBEEFCAF3/bitcoin/blob/armin/re-enable-op-cat/src/test/data/script_tests.json#L2531). What issues or inefficiencies existed with the previous testing strategy?

1. Are there any additional test cases you would like to see implemented that are not covered by the functional tests or the script tests in `script_tests.json`?

<!-- TODO: After a meeting, uncomment and add meeting log between the irc tags

## Meeting Log

### Meeting 1

{% irc %}
-->

<!-- TODO: For additional meetings, add the logs to the same irc block. This ensures line numbers keep increasing, avoiding hyperlink conflicts for identical line numbers across meetings.

### Meeting 2

-->

{% endirc %}
