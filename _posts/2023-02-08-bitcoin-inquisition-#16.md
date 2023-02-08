---
layout: pr
date: 2023-02-08
title: "bitcoin-inquisition #16: Activation logic for testing consensus changes"
link: https://github.com/bitcoin-inquisition/bitcoin/pull/16
permalink: /bitcoin-inquisition-16
authors: [ajtowns]
components: [consensus]
host: ajtowns
status: past
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

## Meeting Log

{% irc %}
17:00 <_aj_> #startmeeting
17:00 <glozow> hi
17:00 <_aj_> aww, no bot
17:00 <pablomartin_> hello
17:00 <_aj_> hi all!
17:00 <svav> Hi
17:00 <codo> hi
17:00 <theStack> hi
17:00 <roze_paul> hi
17:00 <neha> hi
17:00 <kevkevin> hi
17:00 <michaelfolkson> hi
17:00 <_aj_> feel free to say hi everybody, just like classic dr nick. anybody's first time?
17:01 <lightlike> hi
17:01 <_aj_> today we're in a fork repo, https://bitcoincore.reviews/bitcoin-inquisition-16 -- bitcoin inquisition
17:01 <LarryRuane> hi
17:02 <_aj_> did anyone get a chance to look at the pr/repo/etc? y/n
17:02 <glozow> y
17:02 <codo> n
17:02 <lightlike> y (0.5)
17:02 <kevkevin> y (0.3)
17:02 <neha> n
17:02 <theStack> n
17:02 <svav> The notes yes
17:02 <roze_paul> y
17:02 <michaelfolkson> Also 0.5y
17:02 <pablomartin_> y
17:02 <LarryRuane> 0.2y
17:03 <dzxzg> n
17:03 <hernanmarino> Hi ! Only the notes and related links, i find it super interesting 
17:04 <_aj_> so, i guess "ask questions any time" is probably a given, but in case it's not - ask questions any time! going through the questions from the notes...
17:04 <_aj_> Did you review the PR? Concept ACK, approach ACK, tested ACK, or NACK?
17:05 <LarryRuane> concept ack, running the branch now, haven't really tested anything (not super clear on how to do that)
17:05 <michaelfolkson> Concept ACK, unsure on Approach ACK
17:06 <roze_paul> C-ack -> I find michaelfolkson's point [iiuc] on custom signets per softfork interesting. Played with the fork, but not the specific pr
17:06 <_aj_> well, the next question is concept-y, the one after is test-y
17:06 <_aj_> Why do we want to deploy consensus changes that aren’t merged into Bitcoin Core? What problems (if any) are there with merging the code into Bitcoin Core, and then testing it on signet afterwards?
17:07 <roze_paul> finding bugs in the consensus code is immeasurably better to do on signet than mainnet?
17:07 <roze_paul> and we want to test and build on top of them as well
17:07 <glozow> I imagine if we find a bug, fix it in Core, then later activate the soft fork, there could be a few unupgraded nodes enforcing a different set of rules
17:08 <LarryRuane> merging even unactivated consensus changes can break existing functionality as a side-effect
17:09 <_aj_> roze_paul: yep -- finding consensus bugs in mainnet is pretty painful, and can shut down your lightning nodes while you mess around with upgrading, eg
17:10 <_aj_> i guess another question is why do it on signet, rather than just on regtest?
17:10 <LarryRuane> glozow: +1 good point ... do we have to assume all nodes (or nearly all) are running actual releases? many of us run master branch, but not for long usually
17:11 <LarryRuane> maybe it isn't possible (or easy) to test LN on regtest?
17:11 <glozow> LarryRuane: well, if we add something to Core it would eventually go into a release
17:12 <lightlike> Also it's extremely hard to get consensus changes merged into core without overwhelming consensus, the threshold here is much lower
17:12 <_aj_> you can point multiple nodes at a signel regtest -- we do that ourselves in the functional tests; so i think LN testing is okay
17:12 <hernanmarino> _aj_ : is it because signet is a more "open" network ?
17:13 <michaelfolkson> glozow: Unless it was reversed (not that I'm recommending adding consensus changes to Core only to reverse them prior to a release)
17:13 <neha> regtest is pretty uniform -- on signet you might have different versions of code, different hardware, etc
17:14 <_aj_> hernanmarino: so there's two reasons i think matter (not everybody agrees!) -- one is that if you throw test vectors onto signet, it's much easier to actually validate them. we have lots of test vectors for taproot into core's internal tests, but actually making them available to other people to test their software isn't that easy; arguably that's part of why btcd had bugs recently
17:14 <LarryRuane> "why do it on signet, rather than just on regtest?" -- don't all softforks activate at block 1 on regtest, so we couldn't test that softfork upgrades go smoothly?
17:14 <_aj_> hernanmarino: another is that maybe it's interesting to do integration tests with different software, rather than running the entire environment yourself (since you can't make regtest available publicly without getting random reorgs)
17:14 <michaelfolkson> You don't ever see the activity on someone's regtest if we are interested in how a potential consensus change is being used to build things
17:14 <glozow> signet is more suitable for integration testing - you can have lots of companies, applications, different implementations/versions of LN nodes, etc. doing stuff on there at the same time
17:15 <hernanmarino> _aj_ : I agree on both, my original comment was referring to your second reason 
17:17 <_aj_> LarryRuane: you can use -vbparams to change when forks activate on regtest, if you want to test how upgrades go. but maybe that doesn't really test "smoothness" since it's all a very labratory environemnt
17:17 <_aj_> okay, before we go on, does anyone have any questions about how the heretical deployment idea works that they'd like to ask now?
17:18 <michaelfolkson> Why bother with signaling if every mined block needs to get signed by the block signer?
17:18 <_aj_> that's a good question!
17:19 <neha> i imagine because signaling is a very important thing to test...
17:19 <michaelfolkson> It is kinda testing signaling but in a completely different environment to what it would be on mainnet. No block signers on mainnet for one
17:19 <_aj_> the point of signalling is to be able to deal with custom signets -- if i'm pointing my inquistion node at one signet, how do i know when to enforce APO on it? you can't hardcode a time or height, because the signer might not have upgraded to enforce the rules at any particular time or height
17:20 <_aj_> neha: the signalling for heretical deployments is mostly different code to that used for mainnet, so it's not a super useful test in that sense :(
17:20 <LarryRuane> curious why `timeout` is a timestamp instead of block height? ... oh i think your last comment answers that question
17:20 <lightlike>  since the deployment mechanism is differerent (Heretical Deployment), I don't see much point in testing this.
17:21 <neha> _aj_: then i don't understand why you couldn't just go with "whenever the block signer says to enforce APO"
17:21 <_aj_> right -- so if you hardcoded signet's blockheight of 129000 to activate, then a custom signet would have to waste time mining 120k blocks just to catch up
17:21 <_aj_> neha: that's what's being signalled!
17:21 <neha> ah, ok
17:21 <glozow> so the reason is we have a method of communicating when to activate despite not everyone running the exact same software
17:22 <_aj_> neha: you just mine a single block with a particular version to signal activation or deactivation
17:22 <_aj_> which is a perfect lead in to...
17:22 <michaelfolkson> A custom signet is a totally different chain? What is its relevance to the default signet?
17:22 <_aj_> When have ANYPREVOUT and CHECKTEMPLATEVERIFY been activated on signet according to this logic? If we found a bug and needed to make substantial changes, how would we do that? Would that result in a signet hard fork?
17:22 <glozow> My node says CTV activated at height 106704
17:23 <_aj_> michaelfolkson: every signet shares the same genesis block, but every block after that is distinct due to the signet signature committing to the signet signing key
17:23 <glozow> no APO yet, I assume that'll be after PR #18?
17:23 <michaelfolkson> If I set up a custom signet with me as a block signer I control the block heights, times of when things are activated on my custom signet. But I don't care when things are activated on the default signet?
17:23 <_aj_> glozow: yes; or in the 23.0 branch
17:23 <lightlike> i found this quite confusing: it seems that in the PR branch neither have activated, in the 23 branch both have activated and in the 24.0 branch only CTV but not APO has activated. Is there a logic to this?
17:24 <glozow> My answer is from running my node on signet and calling getdeploymentinfo
17:24 <_aj_> lightlike: the 24.0 branch has [this PR] [CTV] merged, but [APO] unmerged, so the 24.0 branch is unable to tell you anything about APO
17:24 <glozow> ahhhh
17:25 <lightlike> _aj_: but why is [APO] only merged in 23 but not in 24?
17:25 <_aj_> https://github.com/bitcoin-inquisition/bitcoin/pull/18/commits/04683f69b5f503325610a6fac6379a8fd979d968 -- is the commit that sets APO up as an heretical deployment
17:26 <_aj_> lightlike: 24.0 is branched directly from core so doesn't include anything that inquisition merged for 23.0 until a PR gets merged. i'm trying to give a little time for people to review PR's before merging them
17:28 <roze_paul> @glozow, to be sure, your APO is also activated at 106704? My 23-node has both apo & ctv activated at 106704
17:28 <_aj_> so if you run `bitcoin-cli -signet getdeploymentinfo $(bitcoin-cli -signet getblockhash 106271)` you'll see CTV was signalled for activation at block height 105942
17:29 <_aj_> https://mempool.space/signet/block/105942?showDetails=true&view=actual#details -- which has the magic 0x60007700 version; 0x77 being 119, CTV's bip number
17:29 <_aj_> What is the point of the DEACTIVATING state?
17:30 <michaelfolkson> Phasing out a soft fork proposal (after a bug or just not being used)
17:30 <_aj_> why phase it out though? if there's a bug, why not just stop immediately?
17:31 <glozow> Is the question why we don't go directly from ACTIVE to ABANDONED, and have 432 blocks of DEACTIVATING isntead?
17:31 <_aj_> yep, that was the intent of the question
17:31 <roze_paul> +1.intermediate annulation of a softfork...waits until next period to be abandoned [inactive]
17:31 <michaelfolkson> I still don't understand the custom signet point. They share a genesis block. So what? :)
17:31 <neha> is it because of the interaction with timeout?
17:31 <glozow> I assumed it would have something to do with reorgs but I'm not sure :(
17:32 <michaelfolkson> But it seems like because of the custom signet point you want to coordinate phasing in and out of soft fork proposals
17:32 <d33r_gee> noob question: how do you compile a version of bitcoind (bitcoin-Inquisition) that's different from the regular main repo? More specifically can both instance run on the same machine?
17:32 <michaelfolkson> Rather than just having AJ announcing block heights, times of activations or deactivations
17:32 <_aj_> michaelfolkson: (there's no "so what" -- they share a genesis because that made it easier for wallets that wanted to hardcode the genesis and would have found it hard to deal with a different genesis for each custom signet)
17:33 <michaelfolkson> _aj_: Ok but after the genesis block they can be totally different chains? No?
17:33 <michaelfolkson> Totally independent other than the genesis block?
17:33 <_aj_> so it's an easier answer than that -- it's just to give people a chance to withdraw funds they might have locked into the soft fork. once the fork is deactivated or replaced, they might not be able to spend the funds at all (even if it's anyonecanspend that doesn't work if your tx gets rejected for not being standard)
17:33 <LarryRuane> d33r_gee: "can both instance run on the same machine?" -- yes
17:33 <_aj_> michaelfolkson: (they will always be totally different chains)
17:34 <roze_paul> @d33r_gee I've almost forgotten, but dm me later...it comes down to following the build directions and ensuring your data-dir isnt the same, IIRC
17:35 <LarryRuane> _aj_: that's interesting! to make sure I get it, funds on signet are somewhat precious (even tho of course no monetary value)?
17:35 <glozow> oh, duh
17:35 <roze_paul> (there are build directions on the bitcoin github page per mac/linux/win)
17:35 <_aj_> LarryRuane: well, not so much precious, as we'd like to not have useless entries sitting in the utxo set forever
17:35 <LarryRuane> oh right, +1
17:35 <d33r_gee> LarryRuane ah thanks!
17:35 <d33r_gee> roze_paul will do! Thank you!
17:35 <glozow> I had a question about abandoning, i.e. how it doesn't cause a hard fork. Is it because we are assuming everybody who followed the activation also followed the deactivation signaling? So there's nobody out there who activated the soft fork but won't also deactivate it?
17:36 <glozow> Well I guess it's signet so it's the same miner anyway
17:36 <_aj_> glozow: exactly -- the soft fork includes both the activation and deactivation as a bundle.
17:36 <glozow> gotcha
17:36 <michaelfolkson> glozow: It is a hard fork for those running an old version of bitcoin-inquisition not knowing about the attempt to phase it out
17:37 <instagibbs> it would be an end of "censorship" for those who don't know about the activation/deactivation
17:37 <glozow> there isn't a bitcoin-inquisition version that doesn't have both activation and deactivation logic tho
17:37 <_aj_> michaelfolkson: it's only a hardfork for people who've modified their inquisition software to not know about the deactivation signalling
17:38 <_aj_> Why is min_activation_height removed?
17:38 <michaelfolkson> _aj_: The deactivation signaling is included in the bitcoin-inquisition release with the activation signaling?
17:38 <LarryRuane> I remember luke-dashjr made this point about reducing the max block size -- it should be auto-expiring (deactivating) right from the start, so that the block size limit can be increased later without a hardfork, I though that was cool
17:38 <lightlike> because we don't need a configurable period between lock-in and activation in the new state model anymore - with heretical deployments, it activates automatically in the next period
17:38 <michaelfolkson> I thought for some soft fork proposals you wouldn't ever want to deactivate it
17:38 <_aj_> LarryRuane: yes; can you find where he wrote that? i looked the other day and couldn't remember
17:39 <glozow> michaelfolkson: observe that they are implemented in 1 commit
17:39 <_aj_> michaelfolkson: for mainnet activations you probably don't (or we haven't in the past anyway), but for signet-only activations, probably we always do
17:40 <_aj_> michaelfolkson: the signet miner can always choose not to signal for deactivation, of course
17:40 <LarryRuane> _aj_: not sure if I saw it written down, but it's in this presentation (which is really excellent in general, by the way) https://www.youtube.com/watch?v=CqNEQS80-h4
17:40 <_aj_> LarryRuane: oh! that would explain why i couldn't find it
17:41 <neha> https://diyhpl.us/wiki/transcripts/magicalcryptoconference/2019/why-block-sizes-should-not-be-too-big/
17:41 <_aj_> >> Why is min_activation_height removed? << -- anyone know the answer?
17:41 <glozow> I think lightlike said answered, there's no need to wait between lock in and activation?
17:42 <_aj_> oh, i'm blind, great!
17:42 <lightlike> that was my guess
17:42 <glozow> Also, just to clarify, even if no abandonment is signaled, the soft fork still eventually deactivates at the timeout right? https://github.com/bitcoin-core-review-club/bitcoin/blob/d3028d44d97629f821ea60c62515fd775a790f9b/src/versionbits.cpp#L79
17:42 <michaelfolkson> Definitely no deactivations for mainnet activations. Unless complete disastrous emergency. That would not be fun
17:42 <_aj_> also, because of the same problem above -- heights on signet in general don't work if you care about custom signets
17:43 <_aj_> glozow: yes, but i think the timeouts i put in for APO and CTV are in 2031, so...
17:43 <glozow> oh, haha
17:44 <_aj_> Why is Taproot buried?
17:44 <LarryRuane> because it was activated "long enough" ago?
17:45 <_aj_> that's a good reason, but not the reason!
17:45 <glozow> I think it's effectively buried already, but rpc/blockchain.cpp needs code that's going to be deleted to add Heretical Deployments?
17:45 <lightlike> because it' incompatible with the new heretical deployment scheme?
17:46 <_aj_> if you didn't bury it, you'd have to make it an heretical deployment; and that would (at least at one point) then mean that it would timeout eventually, but we don't want taproot to timeout
17:47 <michaelfolkson> You might want to sync up bitcoin-inquisition with the consensus rules of Core (and deactivate before 2031). Say if a opcode was given a different OP_NOP on bitcoin-inquisition to the one it ended up with in an actual soft fork activation in Core
17:47 <LarryRuane> can't you make timeout maxint? (0x7fff...)?
17:47 <_aj_> i think in the current code you could just make it be SetupDeployment({.always = true}) or so though...
17:47 <michaelfolkson> I guess we're not thinking particularly long term with default signet, bitcoin-inquisition. Happy to do resets
17:47 <_aj_> LarryRuane: yeah, exactly
17:48 <_aj_> michaelfolkson: presumably you'd want to test the OP_NOP/OP_SUCCESS in signet before activating it in core, so you'd deactivate the conflicting thing before that even
17:48 <_aj_> What is the purpose of AbstractThresholdConditionChecker and ThresholdConditionCache in versionbits.h?
17:50 <glozow> Abstract class for telling us the deployment status of a soft fork is, which can either be implemented through a version bits checker applying BIP9 / Heretical Deployment logic to blocks, a cache that just looks up the values, or something else.
17:50 <roze_paul> so the burying commit is by changing the timeout to maxint, or the bury is done in another way?
17:51 <_aj_> roze_paul: the burying is done by changing the activation method from BIP9 to just "it's active as of this height". for taproot and signet, the height has always been 0, so this is easy, even despite the custom signet problem we might have elsewhere. (taproot got merged into core just before signet did)
17:52 <_aj_> glozow: yep, pretty much; though i personally think the "abstract" is false advertising
17:52 <_aj_> Could/should the large commit be split up further? If so, how? If not, why not?
17:52 <theStack> is there any reason why taproot hasn't been buried yet in core?
17:52 <glozow> if anybody's interested, we've done a review club on burying deployments and deploymentstatus in the past https://bitcoincore.reviews/19438
17:53 <_aj_> theStack: see #23505 and other PRs
17:53 <_aj_> theStack: there's reasons, but no particularly profound ones?
17:54 <_aj_> (it did get split up further after those notes got written and gleb made some suggestions! maybe it could be more split up for next time?)
17:54 <michaelfolkson> It was buried, no? In #23536
17:54 <theStack> _aj_: oh interesting, apparently i even reviewed that one and can't remember :X
17:55 <theStack> the latest try seems to be https://github.com/bitcoin/bitcoin/pull/26201
17:55 <lightlike> There's also #26201 (open)
17:55 <michaelfolkson> Oh ok
17:55 <_aj_> Do any of the changes here make sense to include in Bitcoin Core?
17:56 <glozow> probably not?
17:57 <glozow> -renounce seems like it would be a footgun
17:57 <_aj_> Final questions that I skipped over are: "Were you able to compile and run the code?" "Were you able to test the code? What tests did you run?" -- happy to hang around if people want to discuss that beyond a y/n
17:57 <_aj_> glozow: i think some of the little bits of versionbits can be included -- removing the `params` arguments for AbstractThrCC
17:58 <michaelfolkson> I'm a bit scared running Bitcoin Core signet and bitcoin-inquisition on the same machine. Experienced any problems _aj_ switching between them on the same machine?
17:58 <roze_paul> I ran the code, not this pr specifically, just the main branch. Didn't run any tests iirc
17:58 <_aj_> michaelfolkson: i run them both with separate datadirs?
17:59 <roze_paul> +1 _aj_
17:59 <_aj_> glozow: https://github.com/ajtowns/bitcoin/commits/202301-versionbits has two commits i've been thinking about
18:00 <_aj_> michaelfolkson: if you want to meaningfully switch between them, running -rescan or -reindex is probably worthwhile, i guess?
18:00 <_aj_> okay, that's time!
18:00 <_aj_> #endmeeting>>)
{% endirc %}
