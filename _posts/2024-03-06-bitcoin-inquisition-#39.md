---
layout: pr
date: 2024-03-06
title: "bitcoin-inquisition #39: Re enable OP_CAT"
link: https://github.com/bitcoin-inquisition/bitcoin/pull/39
permalink: /bitcoin-inquisition-39
authors: ["0xBEEFCAF3", EthanHeilman]
components: ["consensus"]
host: EthanHeilman
status: past
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

1. What are the various conditions under which the execution of OP_CAT may result in failure?

1. OP_CAT is defined as 0x7e. Even after replacing an OP_SUCCESS opcode, libraries can continue to use 0x7e to represent concatenation operations. Why is this the case?

1. In [`deploymentinfo.cpp`](https://github.com/0xBEEFCAF3/bitcoin/blob/armin/re-enable-op-cat/src/deploymentinfo.cpp#L96), there are both an `OP_CAT` flag and a `DISCOURAGE_OP_CAT` flag. What is the rationale behind having both of these?

1. When does consensus consider OP_SUCCESS126 replaced by OP_CAT?

1. What is the expected behavior when neither flag is set?

1. Why is it important to verify if OP_CAT is being executed in a non-segwitv0 or base-script context at [`L474:interpreter.cpp`](https://github.com/0xBEEFCAF3/bitcoin/blob/armin/re-enable-op-cat/src/script/interpreter.cpp#L475) rather than inside the opcode definition?

1. This PR introduces new semantics for taproot-related script tests in `script_tests.json`. For example, [this test](https://github.com/0xBEEFCAF3/bitcoin/blob/armin/re-enable-op-cat/src/test/data/script_tests.json#L2531). What issues or inefficiencies existed with the previous testing strategy?

1. Are there any additional test cases you would like to see implemented that are not covered by the functional tests or the script tests in `script_tests.json`?


## Meeting Log

{% irc %}
17:01 <EthanHeilman> #startmeeting
17:01 <EthanHeilman> Hi
17:01 <stickies-v> hi
17:01 <arminsdev> Hi
17:01 <maxedw> hi
17:01 <reardencode> hi!
17:01 <kouloumos> hi
17:01 <Guest21> hello
17:01 <kevkevin> hi
17:01 <Al79> hI
17:01 <dergoegge> hi
17:01 <monlovesmango> hello
17:01 <effexzi> Hi every1 
17:01 <cbergqvist> hi
17:02 <EthanHeilman> Feel free to post any questions you might have about the PR https://github.com/bitcoin-inquisition/bitcoin/pull/39 to reenable OP_CAT.
17:03 <EthanHeilman> Did everyone get a chance to read the PR?
17:03 <LarryRuane> hi
17:03 <glozow> Spent some time, but I'm new to script interpreter code
17:03 <stickies-v> same here!
17:04 <instagibbs> ignored the activation code, mostly, but read the script interpreter stuff which im more familiar with
17:04 <reardencode> My one question so far is why in the test_framework/script.py the separate block for marking CAT not-success vs. changing the 2nd-to-last character in line 938 to `d`?
17:04 <kevkevin> have not but I will be mostly lurking today
17:04 <hernanmarino> Hi  !
17:04 <alfonsoromanz> hi
17:04 <maxedw> skimmed through PR and BIP
17:05 <reardencode> BTW, not specific to the PR, but to the BIP and PR club notes, but CAT cannot emulate CSFS - that was a common misconception based on many of us too quickly reading Poelstra's old blog post.
17:05 <kouloumos> a quick look at the PR, read the BIP and mostly context-gathering around OP_CAT
17:05 <EthanHeilman> If you reviewed the PR Concept ACK, approach ACK, tested ACK, or NACK?
17:06 <arminsdev> @reardencode  Thanks for pointing that out! I need to revert that change. In general the changes in this PR should not affect OP_SUCCESS checks
17:06 <hernanmarino> approach ACK here. I'll test it later , i really like this :)
17:06 <instagibbs> approach ACK, would have to dive more into the activation logic to think clearly about how OP_SUCCESSX stuff is handled
17:08 <EthanHeilman> Let's get it started, it sounds like arminsdev addressed reardencode's question
17:08 <LarryRuane> i have a very basic question, what's the difference between the various OP_NOPs and OP_SUCCESS?
17:08 <LarryRuane> do they both just do nothing (successfully)?
17:09 <instagibbs> LarryRuane all NOPs are same, all OP_SUCCESSX are same, but the two classes are different
17:09 <reardencode> presence of SUCCESS skips script execution entirely and makes the tx success.
17:09 <reardencode> er the _input_ success, not the tx
17:10 <LarryRuane> i see thanks
17:10 <instagibbs> interpreter steps over all opcodes, if it sees an op_successx, it immediately succeeds
17:10 <instagibbs> before running the actual script
17:10 <glozow> do repurposed nops have restrictions on what they can do to the stack?
17:10 <EthanHeilman> I'm going to go down the list of questions, but throw any additional questions in
17:11 <instagibbs> glozow and how does that effect re-enabling of something like OP_CAT 🧐
17:11 <LarryRuane> glozow: i would think they must leave the stack unchanged (like a NOP does)
17:11 <glozow> it doesn't, i'm just trying to answer LarryRuane's question
17:12 <EthanHeilman> 2. What are the various conditions under which the execution of OP_CAT may result in failure?
17:12 <reardencode> it means we can only reenable OP_CAT as a SUCCESS replacement in tapscript, but not in legacy/witnessv0 script.
17:12 <glozow> fewer than 2 items, resulting size too big, or usage not allowed?
17:12 <LarryRuane> I could only see 2, not enough items on the stack, or the resulting element too large
17:12 <instagibbs> reardencode without some ... interesting engineering :)
17:13 <arminsdev> So far so good! Fewer than 2 items on the stack, resulting item is too large and script verify flags
17:13 <arminsdev> There is one more
17:14 <Ayelen> OP_CAT fails if there are less than two values on the stack or if the size of the result is more than size of 520 bytes.
17:14 <Guest21> is MAX_SCRIPT_ELEMENT_SIZE = 520 a consensus rule or policy rule ?
17:15 <arminsdev> Hint that we re-enable CAT by replacing OP_SUCCESS126
17:15 <reardencode> Guest21: consensus (but prior to CAT we didn't have an example of it needing to be enforced on an element pushed back to the stack IIUC)
17:16 <reardencode> arminsdev: when it's executed in witnessv0/legacy script?
17:16 <arminsdev> reardencode correct!
17:17 <Guest21> so its not consensus rule for tapscript?
17:17 <rot13maxi> I saw that there is a new `SCRIPT_VERIFY_DISCOURAGE_OP_CAT` flag being added. Why is there also `SCRIPT_VERIFY_OP_CAT`? Is that to have something to toggle on when it gets activated
17:17 <EthanHeilman> OP_FALSE IF OP_SUCCESS126 END_IF OP_FALSE OP_VERIFY --> success
17:17 <EthanHeilman> vs
17:17 <EthanHeilman> OP_FALSE IF OP_CAT END_IF OP_FALSE OP_VERIFY --> failure
17:17 <arminsdev> rot13maxi thats one of the questions we're going to cover
17:17 <EthanHeilman> rot13maxi thats question 4, lets jump to that: In deploymentinfo.cpp, there are both an OP_CAT flag and a DISCOURAGE_OP_CAT flag. What is the rationale behind having both of these?
17:17 <reardencode> Guest21: it is a consensus rule for all incoming stack elements in witnessv0 and tapscript, and with the addition of CAT also for elements pushed back to the stack by script.
17:18 <rot13maxi> arminsdev cool
17:19 <arminsdev> I suppose we can jump into that question now. Any ideas?
17:20 <EthanHeilman> reardencode "with the addition of CAT also for elements pushed back to the stack by script" how does OP_CAT add this rule? Is there something different about the OP_PUSHDATA logic?
17:20 <LarryRuane> rot13maxi: I believe the discourage flags are in case later we want to deactivate the softfork (I notice that the early SFs like P2SH don't have discourage flags because we know they'll never be undone)
17:21 <reardencode> EthanHeilman: because CAT directly manipulates the stack it has to separately implement the length restriction, vs. PUSHDATA already has the restriction is what I meant
17:21 <EthanHeilman> reardencode Oh, I get what you are saying
17:22 <instagibbs> OP_CAT didn't have the restriction, hence part of th reason it was disabled 
17:22 <hernanmarino> +1 to LarryRuane but i thinks it is only related to bitcoin inquisition  because forks are activated differently, and can be desactivated 
17:22 <EthanHeilman> IIRC OP_CAT did have the restriction
17:23 <instagibbs> only for like... a day, one sec
17:23 <rot13maxi> there is also a policy limit on taproot witness stack item size of 80 bytes (https://github.com/bitcoin/bitcoin/blob/ab5dfdbec1143f673f4d83acd4e335bb2c51034e/src/policy/policy.h#L45) which I ran into when playing with CAT on regtest. Doesn't directly affect this PR, but is another limit that comes into play for using cat in practice
17:24 <EthanHeilman> OP_CAT was restricted to 5000 bytes before it was disabled, but interestingly in the commit that disabled it, Satoshi also changed OP_CAT to restrict it to 520 Bytes
17:24 <EthanHeilman> https://github.com/bitcoin/bitcoin/commit/4bd188c4383d6e614e18f79dc337fbabe8464c82#diff-27496895958ca30c47bbb873299a2ad7a7ea1003a9faa96b317250e3b7aa1fefL390
17:24 <instagibbs> 757f0769d8360ea043f469f3a35f6ec204740446 satoshi adds a result restiction
17:25 <kouloumos>  Regarding the MAX_SCRIPT_ELEMENT_SIZE, Steven Roose [propose yesterday](https://github.com/bitcoin/bips/pull/1525#issuecomment-1979297869) a total stack size limit instead of per-item size limit. Any thoughts on that? Does it allow for any other use-cases?
17:25 <instagibbs> 4bd188c4383d6e614e18f79dc337fbabe8464c82 satoshi changes it to 520, but also disabled
17:26 <instagibbs> (end digression!)
17:28 <EthanHeilman> What happens in soft fork when half of the network has adapted it but half the network has not and someone publishes a transaction on the p2p network that uses the softforked behavior? (related to the question)
17:28 <arminsdev> SCRIPT_VERIFY_OP_CAT essentially decouples OP_SUCCESS verify flags from OP_CAT usage. Take a look at how this is being used here: https://github.com/0xBEEFCAF3/bitcoin/blob/armin/re-enable-op-cat/src/script/interpreter.cpp#L1985
17:28 <arminsdev> By introducing the discouragement flag, mempool policy can inform developers to not use CAT during a activation period.
17:28 <arminsdev> Take a look https://github.com/0xBEEFCAF3/bitcoin/blob/armin/re-enable-op-cat/src/validation.cpp#L1021
17:29 <glozow> so DISCOURAGE_OP_CAT is for granularity vs DISCOURAGE_OP_SUCCESS?
17:29 <rot13maxi> I get the rational of having a flag to specifically target OP_CAT for "allow" or "disallow". I'm curious about the rationale for having both
17:30 <Guest42> hi
17:32 <EthanHeilman> It is like a two phase commit, OP_CAT = true,  DISCOURAGE_OP_CAT = true. Until the network has fully moved to OP_CAT = true. Then you can set DISCOURAGE_OP_CAT =false. I believe this approach was taken with segwit as well right, right?
17:33 <EthanHeilman> 6. What is the expected behavior when neither flag is set?
17:35 <glozow> It's just an op success?
17:37 <arminsdev> glozow correct!
17:37 <EthanHeilman> and op success is discouraged
17:37 <glozow> so, rejected in policy and accepted in consensus
17:38 <EthanHeilman> 7. Why is it important to verify if OP_CAT is being executed in a non-segwitv0 or base-script context at L474:interpreter.cpp rather than inside the opcode definition
17:38 <EthanHeilman> https://github.com/0xBEEFCAF3/bitcoin/blob/armin/re-enable-op-cat/src/script/interpreter.cpp#L475
17:38 <EthanHeilman> this question is a fun one!
17:38 <hernanmarino> glozow: thanks for clarifying that, i was wondering about the meaning of discouraged in this context 
17:39 <instagibbs> "pretty please don't use this, this an upgrade hook"
17:40 <arminsdev> For those that want to dig a bit deeper into the different flags and their responsibilities take a look at this gh thread
17:40 <arminsdev> https://github.com/bitcoin-inquisition/bitcoin/pull/39#discussion_r1480760257
17:41 <reardencode> EthanHeilman: otherwise it would fail before getting to the opcode execution even for Tapscript?
17:41 <Ayelen> 7- to avoid exponential memory usage?. Tapscript enforces a maximum stack element size of 520 bytes
17:42 <kouloumos> I can't find when/if the discourage flag was used with previous softforks, links appreciated
17:42 <EthanHeilman> almost! What would be the behavior for non-tapscript transactions if we enabled OP_CAT and put the check IS OPCAT ENABLED in the script definiition
17:43 <glozow> by opcode definition, do you mean L543?
17:44 <EthanHeilman> yes
17:45 <hernanmarino> i have a question related to the discourage flag... this is only related to how bitcoin inquisition works right ? Activation in the real Bitcoin mainnet will not work this way, will it ?
17:45 <EthanHeilman> If implemented it like:
17:45 <EthanHeilman>  L543: case OP_CAT: {
17:45 <EthanHeilman>  L544:     if not tapscript ... return set_error(serror, SCRIPT_ERR_DISABLED_OPCODE); // Disabled opcodes (CVE-2010-5137).
17:49 <reardencode> not seeing a difference :-\
17:49 <Mccalabrese> all nontapscript transactions would fail?
17:49 <arminsdev> hernanmarino thats a good question. It certainly could operate the same way in mainnet. It depends on what the bitcoin core policy is for consensus changes
17:49 <EthanHeilman> I took me a half a day to figure this out.
17:49 <EthanHeilman> Consider the following non-tapscript script
17:49 <EthanHeilman> OP_FALSE IF OP_CAT END_IF OP_TRUE
17:49 <EthanHeilman> Currently this script will fail because the check for if OP_CAT is a disabled op code happens before we reach the logic that checks conditionals
17:50 <reardencode> oh, but the if check there hiding on the line right above the switch(opcode). would be a consensus change for legacy scripts.
17:50 <reardencode> nice one.
17:51 <EthanHeilman> Whereas if we move that check into the op code definition (L543) then
17:51 <EthanHeilman> OP_FALSE IF OP_CAT END_IF OP_TRUE
17:51 <EthanHeilman> will succeed for non-tapscript transactions. Such a change will result in a hardfork.
17:51 <EthanHeilman> reardencode exactly!
17:51 <Ayelen> EthanHeilman: thanks
17:51 <instagibbs> feel like we should have a term for things that fail if interpreter hits it unconditionally
17:52 <dergoegge> EthanHeilman: would any of our tests catch this?
17:52 <dergoegge> (i don't think so)
17:53 <EthanHeilman> Yes, in fact I first noticed this because an existing script test caught it. For more details see:
17:53 <EthanHeilman> https://github.com/bitcoin-inquisition/bitcoin/pull/39#discussion_r1465110469
17:54 <EthanHeilman> I believe the script test that caught it was this one:
17:54 <EthanHeilman> ["'a' 'b' 0", "IF CAT ELSE 1 ENDIF", "P2SH,STRICTENC", "DISABLED_OPCODE", "CAT disabled"],
17:55 <EthanHeilman> so good work to whoever wrote that
17:55 <dergoegge> that's great!
17:55 <EthanHeilman> 8. This PR introduces new semantics for taproot-related script tests in script_tests.json. For example, this test. What issues or inefficiencies existed with the previous testing strategy?
17:56 <glozow> very cool, totally doesn't make this code look scary at all
17:56 <glozow> (the interpreter code in general i mean)
17:56 <arminsdev> test example = https://github.com/0xBEEFCAF3/bitcoin/blob/armin/re-enable-op-cat/src/test/data/script_tests.json#L2530
17:58 <BlueMatt[m]> do we have fuzz tests which can test an old script interpreter and a new one and check that its not a hard fork?
17:58 <instagibbs> differential script fuzzing sounds like a dergoegge question
17:58 <dergoegge> not that i'm aware but i've been meaning to work on it
17:58 <monlovesmango> needing to check/validate multiple previous items on the stack?
17:59 <EthanHeilman> I would love to see that. I did a bit of fuzzing on OP_CAT and I want to do more.
18:00 <hernanmarino> dergoegge: that would something nice to have, I'm not an expert in fuzz testing but I'm willing to help if you or someone takes the lead
18:00 <EthanHeilman> For reference, this is that a tapscript script test looked like before we added these new test semantics
18:00 <EthanHeilman> [
18:00 <EthanHeilman>     [
18:00 <EthanHeilman>         "c24f2c1e363e09a5dd56f0",
18:00 <EthanHeilman>         "89a0385490a11b6dc6740f3513",
18:00 <EthanHeilman>         "7e4c18c24f2c1e363e09a5dd56f089a0385490a11b6dc6740f351387",
18:00 <EthanHeilman>         "c0d6889cb081036e0faefa3a35157ad71086b123b2b144b649798b494c300a961d",
18:00 <EthanHeilman>         0.00000001
18:00 <EthanHeilman>     ],
18:00 <EthanHeilman>     "",
18:00 <EthanHeilman>     "0x51 0x20 0x25b1769ec1939759dd5a97f5f02186e986280ae2bd0588ad13f28c8ce5044fa6",
18:00 <EthanHeilman>     "P2SH,WITNESS,TAPROOT",
18:00 <EthanHeilman>     "OK",
18:00 <EthanHeilman>     "TAPSCRIPT (OP_CAT) tests CAT on different sized random stack elements. Script is CAT PUSHDATA1 0x18 c24f2c1e363e09a5dd56f089a0385490a11b6dc6740f3513 EQUAL"
18:00 <EthanHeilman> ],
18:02 <EthanHeilman> This is what that a very similar tapscript script test looks like now
18:02 <EthanHeilman> [
18:02 <EthanHeilman>     [
18:02 <EthanHeilman>         "c24f2c1e363e09a5dd56f0",
18:02 <EthanHeilman>         "89a0385490a11b6dc6740f3513",
18:02 <EthanHeilman>         "CAT 0x4c 0x18 0xc24f2c1e363e09a5dd56f089a0385490a11b6dc6740f3513 EQUAL",
18:02 <EthanHeilman>         "<AUTOGEN:CONTROLBLOCK>",
18:02 <EthanHeilman>         0.00000001
18:02 <EthanHeilman>     ],
18:02 <EthanHeilman>     "",
18:02 <EthanHeilman>     "0x51 0x20 <AUTOGEN:TAPROOTOUTPUT>",
18:02 <EthanHeilman>     "P2SH,WITNESS,TAPROOT,OP_CAT",
18:02 <EthanHeilman>     "OK",
18:02 <EthanHeilman>     "TAPSCRIPT Tests CAT on different sized random stack elements and compares the result."
18:02 <EthanHeilman> ],
18:03 <hernanmarino> new semantic is more human readable and less error prone 
18:04 <EthanHeilman> Yes! And you can edit it by hand without writing code to generate a valid control block so it makes it easy to add new tapscript tests to script_tests.json
18:05 <EthanHeilman> We are five minutes past the hour, I'm happy to lurk and discuss this more, I'm going to bring the meeting to a end
18:05 <EthanHeilman> Please add any comments or questions to the PR
18:06 <rot13maxi> EthanHeilman was there other feedback you were hoping to get but didn't?
18:06 <Guest42> Is there another meeting tomorrow?
18:08 <EthanHeilman> #endmeeting
{% endirc %}
