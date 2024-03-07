---
layout: pr
date: 2024-03-13
title: "bitcoin-inquisition #45: LNHANCE inquisition (CSFS, INTERNALKEY)"
link: https://github.com/bitcoin-inquisition/bitcoin/pull/45
permalink: /bitcoin-inquisition-45
authors: [reardencode]
components: ["consensus"]
host: reardencode
status: upcoming
commit:
---

## Notes

Attendees should familiarize themselves with
[LNHANCE](https://delvingbitcoin.org/t/lnhance-bips-and-implementation/376),
and [LN-Symmetry (Eltoo)](https://bitcoinops.org/en/topics/eltoo/).

TL;DR: LNHANCE is a soft fork proposal for bitcoin which combines 4 total
opcodes: `OP_CHECKTEMPLATEVERIFY`, `OP_CHECKSIGFROMSTACK` (CSFS),
`OP_CHECKSIGFROMSTACKVERIFY`, and `OP_INTERNALKEY`. It repurposes 2 NOPs in
all script types and 2 SUCCESSes in Tapscript only. This combination of
opcodes enables many enhancements for the Lightning Network, along with
enabling other off chain UTXO sharing protocols and more. Concretely, it
enables LN-Symmetry, Timeout Trees, simplified PTLC scripts, unidirectional
non-interactive channels, (better than now) vaults, trustless coin pools, and
more.

As bitcoin-inquisition already contains an implementation of BIP-119
(`OP_CHECKTEMPLATEVERIFY`), implementing LNHANCE on Inquisition only requires
adding implementations of BIN-2024-0003 and -0004.

This Pull Request adds a total of 3 opcodes:
* `OP_INTERNALKEY` in Tapscript only, copies the Taproot Internal Key to the
  stack.
* `OP_CHECKSIGFROMSTACK` in Tapscript only, validates a BIP340 Schnorr
  signature using an item from the stack as the message.
* `OP_CHECKSIGFROMSTACKVERIFY` in all script types, validates a BIP340 Schnorr
  signature using an item from the stack as the message, and leaves the stack
  unchanged.

The semantics of the signature-checking opcodes are similar to Tapscript
opcodes, including the empty signature->false behavior for
`OP_CHECKSIGFROMSTACK`.

### [The code](https://github.com/bitcoin-core-review-club/bitcoin/tree/prbitcoin-inquisition-45)

#### `OP_INTERNALKEY`

Because this PR is for bitcoin-inquisition, the
[implementation](https://github.com/bitcoin-core-review-club/bitcoin/blob/prbitcoin-inquisition-45/src/script/interpreter.cpp#L1309)
of `OP_INTERNALKEY` is remarkably simple. The taproot internal key is already
extracted for use with verifying tapscript `OP_CHECKSIG(VERIFY|ADD)` with the
key `0x01`, so it simply needs to be added to the stack.

#### `OP_CHECKSIGFROMSTACK(VERIFY)`

The implementation of `OP_CHECKSIGFROMSTACK(VERIFY)` is split between the [main opcode
processing](https://github.com/bitcoin-core-review-club/bitcoin/blob/prbitcoin-inquisition-45/src/script/interpreter.cpp#L1318), and a function analogous to `EvalChecksigPreTapscript` and `EvalChecksigTapscript` named [`EvalChecksigFromStack`](https://github.com/bitcoin-core-review-club/bitcoin/blob/prbitcoin-inquisition-45/src/script/interpreter.cpp#L346).

An earlier approach was to add a `SignatureChecker` that could carry the
message rather than generating the message from the transaction, and give CSFS
the exact semantics of existing sigops in their respective script types, but
that approach had two problems: getting BIP340 signing into legacy/segwitv0
scripts became intrusive, and the semantics of legacy/segwitv0 signature
checking are not particularly desirable for a new opcode. As a result the
current implementation uses a separate function specific to CSFS and gives
modern Tapscript-style semantics. Only after changing code approaches did it
become clear that ECDSA checking might not be desirable in these new sigops.
The commit history still reflects the removal of ECDSA in a separate commit.

Outside of these changes in `interpreter.cpp`, the only non-flag change in
production code is to allow variable length input to BIP340
signature-checking.

### Testing

Tests for both CHECKSIGFROMSTACK and INTERNALKEY have been added to
[tx_valid.json](https://github.com/bitcoin-core-review-club/bitcoin/blob/prbitcoin-inquisition-45/src/test/data/tx_valid.json#L671)
and
[tx_invalid.json](https://github.com/bitcoin-core-review-club/bitcoin/blob/prbitcoin-inquisition-45/src/test/data/tx_invalid.json#L491)
for the trasnsaction test framework.
[Here](https://gist.github.com/reardencode/9dbc60a6d6e1591905d25bf4d123dfdd)
are some scripts using `bitcoinjs-lib` and `noble-curves` that were used to
generate the vectors.

You can run a regtest node from this branch to use them yourself.

## Questions

1. Did you review the PR? [Concept ACK, approach ACK, tested ACK, or NACK](https://github.com/bitcoin/bitcoin/blob/master/CONTRIBUTING.md#peer-review)? What was your review approach?

2. What does `OP_CHECKSIGFROMSTACKVERIFY` leave on the stack?
   `OP_CHECKSIGFROMSTACK`?

3. In what case can `OP_CHECKSIGFROMSTACK` fail and terminate script
   execution?

4. What will cause `OP_CHECKSIGFROMSTACK` to succeed without checking the
   signature?

4. What length is the `data` argument to `OP_CHECKSIGFROMSTACK(VERIFY)`?

5. How does `OP_INTERNALKEY OP_CHECKSIG` in Tapscript compare to key spend
   in weight?

6. How can the Lightning Network be improved using `OP_CHECKSIGFROMSTACK`
   combined with `OP_CHECKTEMPLATEVERIFY` (BIP-119)?

## Questions relating to an open consideration

1. Why might a user of `OP_CHECKSIGFROMSTACK(VERIFY)` want to check multiple
   stack items?

2. Is it generally secure to use `OP_CAT` to combine multiple items for use
   with CSFS?

3. Should `OP_CHECKSIGFROMSTACK(VERIFY)` be extended to natively support
   checking a signature against multiple stack items?
   (If so, untested
   [code](https://github.com/reardencode/bitcoin/commit/69cbe4fd7c64a64e019a3bfc7aa0ebda7f7ddcde)
   and
   [BIN](https://github.com/reardencode/binana/commit/62856f404dceb0abb2cfc2c9a76b030a39120f79)
   changes are available).

<!-- TODO: After a meeting, uncomment and add meeting log between the irc tags
## Meeting Log

### Meeting 1

{% irc %}
-->
<!-- TODO: For additional meetings, add the logs to the same irc block. This ensures line numbers keep increasing, avoiding hyperlink conflicts for identical line numbers across meetings.

### Meeting 2

-->
{% endirc %}
