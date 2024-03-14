---
layout: pr
date: 2024-03-13
title: "bitcoin-inquisition #45: LNHANCE inquisition (CSFS, INTERNALKEY)"
link: https://github.com/bitcoin-inquisition/bitcoin/pull/45
permalink: /bitcoin-inquisition-45
authors: [reardencode]
components: ["consensus"]
host: reardencode
status: past
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

## Meeting Log


{% irc %}
17:01 <reardencode> #startmeeting
17:01 <reardencode> Hi!
17:01 <mehounme> Hello
17:01 <glozow> hi
17:01 <Guest42> hi
17:02 <monlovesmango> hey
17:02 <cguida> h
17:02 <cguida> hi
17:02 <emzy> hi
17:02 <reardencode> Links: https://bitcoincore.reviews/bitcoin-inquisition-45 https://github.com/bitcoin-inquisition/bitcoin/pull/45
17:03 <reardencode> I'll go through the questions in the notes, but feel free to drop other questions or comments throughout.
17:03 <reardencode> Did you review the PR? Concept ACK, approach ACK, tested ACK, or NACK? What was your review approach?
17:04 <cguida> Didn't do an official review yet! Meaning to soon :)
17:04 <monlovesmango> reviewed but no opinion... here to learn mostly
17:05 <cguida> Probably Concept ACK from me
17:05 <emzy> did no review, so no opinion.
17:06 <reardencode> Bonus question: Have you read the BIPs, or delving thread about this effort?
17:07 <Guest42> no
17:07 <monlovesmango> read bip 119 and delving thread
17:08 <reardencode> https://delvingbitcoin.org/t/lnhance-bips-and-implementation/376 https://github.com/bitcoin-inquisition/binana/blob/master/2024/BIN-2024-0003.md https://github.com/bitcoin-inquisition/binana/blob/master/2024/BIN-2024-0004.md for reference
17:08 <cguida> Yes, I've read those
17:08 <reardencode> 2. What does OP_CHECKSIGFROMSTACKVERIFY leave on the stack? OP_CHECKSIGFROMSTACK?
17:10 <cguida> VERIFY fails the script if the signature fails, otherwise leaves nothing, without VERIFY it pushes 1 for success and 0 for failure
17:10 <cguida> same as CHECKSIG
17:10 <reardencode> cguida: close - hint: CSFSV repurposes a OP_NOP and CSFS repurposes an OP_SUCCESS
17:12 <cguida> ah. CSFSV leaves the 3 inputs on the stack
17:13 <reardencode> right! I've actually found that in practical scripts this behavior can be useful since CSFS(V) are often used to authorize arguments to other ops, eg. a pubkey for delegation, so leaving items on the stack can be desirable.
17:13 <reardencode> 3. In what case can OP_CHECKSIGFROMSTACK fail and terminate script execution?
17:14 <reardencode> cguida already told us that CSFSV does for any invalid signature, but there is also a case that terminates script execution for CSFS
17:14 <cguida> If there are fewer than 3 items on the stack
17:15 <cguida> or if the pubkey is the wrong size
17:15 <reardencode> pubkey the wrong size is a NOP
17:15 <monlovesmango> wrong sig version?
17:15 <cguida> sorry, if the pubkey is size 0
17:15 <reardencode> monlovesmango: close - somewhat more general
17:16 <reardencode> cguida: you're right I didn't account for all cases in writing the question! 0 pubkey, and small stack also fail.
17:17 <monlovesmango> SCRIPT_VERIFY_DISCOURAGE_CHECKSIGFROMSTACK flag?
17:17 <cguida> the sig needs to be a valid bip340 sig
17:18 <reardencode> as monlovesmango alluded, the case I was thinking of is any non-empty invalid signature terminates execution immediately; only a 0-length signature pushes 0 to the stack and continues execution
17:18 <reardencode> This is the same behavior as OP_CHECKSIG in tapscript.
17:19 <reardencode> 4. What will cause OP_CHECKSIGFROMSTACK to succeed without checking the signature?
17:19 <cguida> ok so i was wrong that a 0 is pushed to the stack if sig validation fails?
17:19 <reardencode> cguida already mentioned this one - non-0, non-32-byte pubkeys succeed without doing any sig validation
17:20 <reardencode> cguida: yeah, somewhat surprising, but useful behavior to avoid malleability.
17:20 <cguida> I believe CHECKSIG pushes 0 to the stack for invalid sig, correct?
17:20 <cguida> so this is different from that?
17:21 <reardencode> Honestly, I forget the exact semantics for legacy/witnessv0 checksig. This behavior is copied from Tapscript checksig.
17:21 <cguida> gotcha
17:21 <reardencode> As I mentioned in the notes, I was originally going to make CSFS follow the semantics of other sigops in respective script types, but that pretty quickly showed itself to be a poor path both in code clarity, and in terms of making new things in bitcoin better than old things.
17:21 <cguida> CSFS will succeed if the pubkey is length not in (0,32)
17:22 <reardencode> ^^ yep
17:22 <monlovesmango> what line in code is "non-0, non-32-byte pubkeys succeed without doing any sig validation"?
17:22 <reardencode> monlovesmango: interpreter.cpp:374 on the diff I'm looking at
17:23 <monlovesmango> thank you :)
17:23 <reardencode> 5. What length is the data argument to OP_CHECKSIGFROMSTACK(VERIFY)?
17:23 <reardencode> What length is the data argument to OP_CHECKSIGFROMSTACK(VERIFY)?
17:23 <reardencode> What length is the data argument to OP_CHECKSIGFROMSTACK(VERIFY)?
17:23 <reardencode> sorry, paste trouble.
17:24 <cguida> should be 0 to 520 bytes?
17:24 <reardencode> correct - there are no special limits applied to it beyond those enforced by script.
17:25 <cguida> +1
17:25 <reardencode> BIP340 mixes the message such that non-uniform messages or short messages do not compromise the signing protocol's unforgeability.
17:26 <reardencode> 6. How does OP_INTERNALKEY OP_CHECKSIG in Tapscript compare to key spend in weight?
17:27 <cguida> looks like it's 8 vBytes smaller?
17:27 <reardencode> in key spend, does the pubkey appear in the spend stack?
17:29 <cguida> ah right, this saves 32 bytes, because you don't need to input the pubkey
17:30 <reardencode> in a taproot key spend, the pubkey is taken from the scriptPubKey directly, so currently a tapscript single sig spend is 32 bytes + some overhead more costly. With OP_INTERNALKEY we can get rid of that extra 32 bytes, but we still have the overhead. So, what's the overhead?
17:31 <reardencode> 2 additional witness item lengths, 1 leading controlblock byte, 2 script opcodes. - 5 extra WU
17:32 <reardencode> (open to having missed something here, but I _think_ that's right)
17:32 <cguida> ok so 32 - 5 = 27?
17:32 <reardencode> keyspend looks like this: <sig>
17:33 <reardencode> script spend looks like this: <sig> <script> <controlblock>
17:33 <reardencode> without OP_INTERNALKEY, <script> is: <pubkey> OP_CHECKSIG. with OP_INTERNALKEY, it's OP_INTERNALKEY OP_CHECKSIG.
17:34 <reardencode> for a depth0 script, <controlblock> is: 0xc0<internalkey>
17:35 <cguida> ok so the script is 2 bytes vs 33 bytes, so 31 bytes smaller...
17:36 <reardencode> bah, no, I had this wrong, it's not 5.
17:36 <reardencode> so, compared to key spend, a depth0 1-sig script spend w/o INTERNALKEY costs 2 witness item lengths, plus a 33-byte script plus a 33-byte controlblock extra
17:36 <reardencode> with internalkey, we can cut out 32 of those bytes
17:37 <reardencode> so, compared to a key spend, the script spend using the inernalkay is 2 witness item lengths, plus a 2-byte script plus a 33-byte control block, so 37WU or 9.25vB more costly.
17:38 <reardencode> well that was fun :-D
17:38 <monlovesmango> haha i'm going to have to go back and reread that a bunch of times
17:39 <reardencode> yeah, sorry for being wrong initially. moving on!
17:39 <cguida> yeah haha still noodling on this
17:39 <reardencode> 7. How can the Lightning Network be improved using OP_CHECKSIGFROMSTACK combined with OP_CHECKTEMPLATEVERIFY (BIP-119)?
17:39 <monlovesmango> enables eltoo?
17:39 <cguida> and PTLCs! and things that are arguably LN-adjacent like timeout trees!
17:40 <reardencode> ^^ exactly. cguida is working on PoCing ln-symmetry to compare with using SIGHASH_ANYPREVOUT for the same purpose
17:40 <cguida> :)
17:40 <reardencode> PTLCs are technically possible without CTV/CSFS, but the scripts are much simplified by having them.
17:40 <cguida> LN-symmetry is the new name for eltoo btw
17:41 <monlovesmango> gotcha thanks!
17:41 <cguida> Or I've also heard Symmetry Channels
17:41 <glozow> what would LN symmetry update/settle transactions look like this way?
17:42 <monlovesmango> agree both of those are less confusing than eltoo
17:43 <reardencode> glozow: https://delvingbitcoin.org/t/ln-symmetry-project-recap/359 - basically the same as with ANYPREVOUT, except instead of <sig> | <apo_pubkey> OP_CHECKSIG, we have <sig> <hash> | OP_CTV <pubkey> OP_CHECKSIGFROMSTACK
17:43 <cguida> CTV+CSFS essentially emulates APO
17:44 <reardencode> (that's for the update tx) for settle we just have <> | <hash> OP_CTV
17:45 <reardencode> (where with APO for settle we have <> | <sig> <apo_pubkey> OP_CHECKSIG
17:45 <reardencode> here you can see how APO almost emulates CTV as well
17:46 <reardencode> the differences between APO and CTV are subtle, CTV commits to n-inputs where APO does not, which only matters sometimes, and APO commits to annex (if present) but CTV does not.
17:47 <reardencode> WHich brings us to my next group of questions! :-D
17:47 <reardencode> 1. Why might a user of OP_CHECKSIGFROMSTACK(VERIFY) want to check multiple stack items?
17:47 <reardencode> (that is verify a single signature that commits to multiple stack items)
17:47 <monlovesmango> to validate multiple conditions?
17:48 <glozow> reardencode: thanks
17:48 <reardencode> monlovesmango: roughly, yeah - any more specific cases you can think of?
17:49 <cguida> To be able to commit to arb data on the blockchain without sticking it in the annex :p
17:49 <reardencode> glozow: :)
17:49 <reardencode> cguida: I'd consider that an anti-use-case, and one better served by other existing methods for doing the same.
17:49 <monlovesmango> err no just answering based on gut feelings...
17:50 <monlovesmango> what is the annex?
17:50 <glozow> have another side question - why did you decide to bundle these together? is the thought process that they should be activated together?
17:50 <reardencode> monlovesmango: a currently non-standard additional signed witness data item added in taproot
17:51 <reardencode> glozow: yeah, my thought process is that CTV alone offers only speculative use-cases, but CTV+IKEY+CSFS offers concrete known use-cases, as well as those speculative use-cases.
17:51 <cguida> fine, i guess "arb" data is not what is happening here
17:51 <cguida> but, extra data
17:52 <monlovesmango> is checking multiple items from stack what allows it to work with CTV?
17:53 <cguida> glozow: CTV+CSFS allows emulating APO, so it gets us most (all?) of the stuff APO gets us, plus all the stuff CTV gets us, while minimizing surface area
17:53 <reardencode> to dive in on monlovesmango's idea of committing to multiple things - consider an inheritence use-case - with CSFS on multiple items, you can commit to a locktime, and a pubkey OR template - in this way you don't have to define all possible inheritence scenarios up front, but can delegate to specific keys after specific locktime, or specific templates after other lock times all by 
17:53 <reardencode> pre-signing delegations with your 'main' key.
17:55 <reardencode> monlovesmango: it helps - the other specific case that has come up is something that instagibbs and cguida hit for LN-Symmetry, the need to commit to both the next update tx CTV hash, and force the reveal of the current update tx's settlement tx's CTV hash. In instagibbs prototype he used the annex with APO for that. CTV does not commit to the annex, but CSFS on multiple items would 
17:55 <reardencode> be equivalent.
17:55 <reardencode> 2. Is it generally secure to use OP_CAT to combine multiple items for use with CSFS?
17:55 <reardencode> (assuming that OP_CAT is also active, can it be used instead of having CSFS natively commit to multiple items)
17:56 <reardencode> consider this script: `<delkey> <locktime> || 2DUP CAT <pubkey> CSFS VERIFY CSV DROP CHECKSIG`
17:57 <reardencode> (there should also be 2 sigs in the stack there, oops)
17:59 <reardencode> in the interest of time, I'll just say: It's not secure, because an attacker could shift 1 byte from the locktime into the delkey on the stack and render the delegate key an always successful key for the CHECKSIG operation while still being valid for the CSFS (the same data is verified after the CAT)
17:59 <cguida> CAT strikes me as generally not secure haha :p
17:59 <reardencode> :-D
17:59 <reardencode> So, final question to think on after this: 3. Should OP_CHECKSIGFROMSTACK(VERIFY) be extended to natively support checking a signature against multiple stack items? (If so, untested code and BIN changes are available).
18:00 <reardencode> https://github.com/reardencode/bitcoin/commit/69cbe4fd7c64a64e019a3bfc7aa0ebda7f7ddcde https://github.com/reardencode/binana/commit/62856f404dceb0abb2cfc2c9a76b030a39120f79
18:00 <cguida> I feel like having CTV commit to the annex if present is the cleanest approach. But that's just my gut.
18:01 <reardencode> I think that'd be a great conversation to have - vector-CSFS vs. CAT vs. CTV-annex maybe something to discuss in a follow-up delving post
18:01 <reardencode> Thanks everyone for participating - I have a meeting right now, but happy to answer more questions async here or on other mediums!
18:02 <reardencode> #endmeeting
{% endirc %}
