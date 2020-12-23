---
layout: pr
date: 2020-12-23
title: "Testing Bitcoin Core 0.21 Release Candidates"
components: ["tests"]
host: jarolrod
status: past
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

## Meeting Log

{% irc %}
18:00 <jarolrod> #startmeeting
18:00 <jarolrod> It’s a Christmas Miracle! The Bitcoin Core PR Review Club has returned for a Special Edition on testing the upcoming 0.21 release
18:00 <jarolrod> You have been enlisted to ensure the upcoming Bitcoin Core 0.21 Release is ready for production by going through some of its changes.
18:00 <jarolrod> Here are your mission instructions: https://gist.github.com/jarolrod/6495932dc6b598ddef49e6374b348f4e
18:00 <jarolrod> If you accept this mission, send a ‘hi’ in the chat. (Also so that we know who’s here)
18:00 <hmrawal> hi
18:00 <andozw> hi
18:00 <michaelfolkson> hi
18:00 <effexzi> hi
18:01 <anastasiia> Hi
18:01 <Caralie> hi
18:01 <jarolrod> Is anyone here for the first time?
18:01 <jnewbery> hi
18:01 <ajonas> hi
18:01 <anastasiia> Yes
18:01 <jarolrod> hello there anastasiia, welcome!
18:02 <jarolrod> I have linked to the guide, does everyone have it open?
18:02 <emzy> hi
18:02 <anastasiia> Yes
18:03 <michaelfolkson> Sure do
18:03 <Caralie> yes
18:03 <murtyjones> Yes
18:03 <hmrawal> yes
18:03 <jarolrod> Great. For all who’ve enlisted, here is a a magnifying glass, notebook, and pen. Let’s start inspecting!
18:04 <jarolrod> Those here for the first time: If any question pops up, just go right ahead and say it. You don’t need to ask in order to ask a question.
18:04 <jarolrod> We will begin with the section titled ‘Preparation’
18:04 <jarolrod> You have the option of grabbing the release candidate binary or compiling from source code.
18:05 <jarolrod> we'll wait for everyone to get there copy of the release candidate
18:05 <fodediop> hi
18:06 <Sishir> hi
18:06 <michaelfolkson> Any preference on the side of the core devs? I'm guessing the preference from the tester should be compile from source code
18:08 <jarolrod> hey there fodediop and sishir, we're just getting started. We're grabbing the rc candidate from the testing guide
18:08 <emzy> I downloaded the binary and checked the SHA256 hash of the binary against the gitian build.
18:09 <jarolrod> compiling is preferred, but compiling can take some time depending on the machine. Those  who are not comfortable with compiling should grab the binary
18:10 <felixweis> hi
18:10 <jarolrod> emzy: 🎉
18:11 <jarolrod> welcome felixweis
18:11 <ajonas> emzy: did you use https://github.com/fanquake/core-review/tree/master/gitian-building to check that or the docs on bitcoin core?
18:13 <emzy> ajonas: I have still an old setup for the gitian builds. It is this https://github.com/bitcoin-core/docs/blob/master/gitian-building.md
18:14 <jonatack> hi
18:14 <michaelfolkson> By "old" you mean it shouldn't be followed anymore?
18:14 <murtyjones> For the macOS binary, how do we specify using the /tmp/21-rc-test data directory on launch?
18:14 <felixweis> is the apple signing bug for rc3 tracked somewhere?
18:15 <jarolrod> jonatack: welcome!
18:15 <jonatack> michaelfolkson: istm the goal is to test the binaries, as that is what most people will use...happy to be corrected on that
18:16 <jonatack> jarolrod: thanks ✨
18:17 <emzy> michaelfolkson: good question. I think the docker one from fanquake seems to be easier to set up.
18:17 <felixweis> nevermind
18:18 <jarolrod> does everyone have a copy of the current release candidate?
18:18 <jonatack> murtyjones: you can specify the data directory by passing -datadir=PATH on the command line or datadir=PATH in the bitcoin.conf configuration filse
18:18 <jonatack> file
18:19 <emzy> murtyjones: /Applications/Bitcoin-Qt.app/Contents/MacOS/Bitcoin-Qt -datadir=/tmp/21-rc-test
18:19 <murtyjones> thanks!
18:22 <jarolrod> The testing guide is divided into four missions: `Testing the Wallet`, `Testing Torv3`, `Signet`, and `Anchors`
18:22 <jarolrod> As you go through each section, please bring up any questions or problems that arise
18:22 <jonatack> one thought, the guide says to test the GUI or the command line per your preference, but if you can it's good to test both, as there can be issues in one and not the other
18:25 <jarolrod> To be inclusive, some people may not be too comfortable with the command line. If you are able to test both, then great!
18:26 <emzy> In the .dmg for macOS is afaik only the GUI version included. So I only tested that.
18:29 <jarolrod> emzy: AFAIK that is correct
18:30 <jonatack> the tor conf can be more minimal, e.g. no need to set onlynet=onion
18:31 <emzy> jonatack: I think it is important so see that you can bootstrap from tor only.
18:31 <jonatack> nor proxy/bind either in some cases
18:32 <hmrawal> I can still do the testing for 0.21 on testnet version right?
18:33 <jonatack> hmrawal: yep, the testnet chain is fine, and definitely try signet too
18:33 <hmrawal> jonatack: sure
18:34 <emzy> hmrawal: the tor part in the document adds some mainnet tor V3 onions. They will not work for testnet.
18:34 <murtyjones> should it take a while to connect to peers using tor? my node has been stuck on "Connecting to peers" for a bit and nodes keep appearing and disappearing from the "Peers" window
18:34 <jonatack> emzy: that's true
18:34 <felixweis> signet does IBD much faster
18:34 <jonatack> signet starts up much faster too. my go-to for quick manual testing.
18:34 <emzy> felixweis: because of smaller blocks ;)
18:35 <jarolrod> murtyjones: yes connecting to tor can take some time, we've supplied some torv3 nodes in the bitcoin.conf to try to get around this
18:35 <michaelfolkson> You can't see which connections are anchor in the GUI or CLI (getpeerinfo etc)?
18:35 <murtyjones> (y)
18:36 <emzy> btw. I'm running sxjbhmhob2xasx3vdsy5ke5j5jwecmh3ca4wbs7wf6sg4g2lm3mbszqd.onion
18:36 <felixweis> windows -> network traffic
18:36 <jonatack> michaelfolkson: the anchor connections will be the initial block-only peers. you can see them easily with ./src/bitcoin-cli -netinfo 4
18:37 <hmrawal> not sure but how much size is required in signet
18:37 <felixweis> emzy: which net?
18:38 <emzy> felixweis: mainnet
18:38 <felixweis> can you run a signet instance too please?
18:39 <jonatack> emzy: just connected to you
18:39 <emzy> felixweis: hm. Maybe on another host. This box is busy with the mainnet :)
18:39 <jonatack> if anyone wants to connect to emzy, run this on the command line:
18:39 <jonatack> ./src/bitcoin-cli addnode sxjbhmhob2xasx3vdsy5ke5j5jwecmh3ca4wbs7wf6sg4g2lm3mbszqd.onion onetry
18:39 <emzy> jonatack: I see one onion connection incomming.
18:40 <jonatack> emzy: the subversion should have @jon at the end
18:40 <jarolrod> for those on the tor section, here's some extra-credit work
18:40 <jarolrod> 1. Running `bitcoind` with the `-debug=tor` configuration option lets you see useful info on the onion configuration
18:40 <jarolrod> 2. This release includes a dashboard that lets you see useful network information. Instead of `getpeerinfo`, one can run `-netinfo 4`
18:40 <emzy> jonatack: yes: "70016/Satoshi:21.99.0(@jon)/"
18:40 <jarolrod> thanks jonatack for the tips
18:41 <jonatack> yes, -debug=tor is handy for seeing in the debug log if your tor setup has any issues or is working ok
18:42 <jonatack> it's not too noisy logging-wise so i always use it
18:44 <emzy> felixweis: signet: 4sk25djzsqqscnv4yfbbntiuo6xxbmddfweppmpc6p6wlt33p36iluyd.onion
18:45 <murtyjones> Have to drop off but thanks jarolrod!
18:45 <jarolrod> murtyjones: thanks for testing!
18:46 <jonatack> jarolrod: this idea and guide and the one by ajonas is great. taking action, testing PRs and releases, and reporting feedback are a valuable part of reviewing.
18:47 <hmrawal> I have started signet, says connecting to peers . Is there some config that we should do beforehand ?
18:47 <michaelfolkson> Presumably those are temporary Tor nodes you've put up emzy. Would be good to know of a persistent Signet Tor node when doing Tor testing
18:48 <michaelfolkson> (outside of this session)
18:48 <jarolrod> hmrawal: the main config is to enable signet in your bitcoin.conf, one note is that for many it takes some time to connect as it is a new network
18:48 <felixweis> emzy, thanks still trying to get tor working
18:48 <jonatack> i have 4 tor v3 onion peers in signet ATM
18:48 <jarolrod> hmrawal: emzy put up a signet tor node in the chat, you can addnode it
18:49 <emzy> michaelfolkson: I could move the onions to some server. If people are interested.
18:49 <michaelfolkson> Persistent jonatack? Can I have one? :)
18:49 <jonatack> two testing 0.21.0 and two running master (0.21.99)
18:49 <jonatack> qlci54ryrj6ywxgki5vvf45fwtp3yhdxxftgnhczvo37qpc2abqcjoid.onion:38333
18:49 <michaelfolkson> Thanks
18:49 <jonatack> v7ajjeirttkbnt32wpy3c6w3emwnfr3fkla7hpxcfokr3ysd3kqtzmqd.onion:38333
18:49 <jarolrod> jonatack: thank you! ✨
18:49 <jonatack> those two are 0.21
18:49 <jonatack>  hx3x3dhdxd5jbz5popeydcehuj5bpekztoya5b7ymvidlvgj6ean6pid.onion:38333
18:49 <jonatack> lktswnpsh3b7ctsvnf7xrjfbesho5l7i3fds2kwvmzufjv7mzgrgoiid.onion:38333
18:50 <michaelfolkson> They are running on VPS?
18:50 <jonatack> those two are 0.21.99 (master), i think most of them are persistent, maybe run by kalle or aj
18:52 <ajonas> With < 10 min left, are people close to being able to leave their comment on #20555?
18:52 <hmrawal> Okay, I need a little help. I am running bitcoin qt and in another tab in terminal I entered jonatack's terminal command to add emzy's node but I get an error saying I need to start bitcoind server
18:53 <jarolrod> hmrawal: iirc you cannot use bitcoin-cli to talk to bitcoin-qt
18:53 <jonatack> hmrawal: try entering it on the GUI (bitcoin qt) console
18:54 <jarolrod> as jonatack said
18:54 <sipa> jarolrod: you can, if bitcoin-qt was started with -server option
18:54 <ajonas> or you an add to your conf and restart
18:54 <jarolrod> sipa: thanks, didn't know that!
18:54 <emzy> hmrawal: on the GUI you have to use the console window (in bitcoin-qt) and type "addnode 4sk25djzsqqscnv4yfbbntiuo6xxbmddfweppmpc6p6wlt33p36iluyd.onion onetry"
18:55 <emzy> ^^ for a signet node
18:55 <jarolrod> We're getting close to time everyone, 5 minutes!
18:56 <jarolrod> Thanks everyone for testing, but the mission is not done!
18:57 <jarolrod> please report back your findings here: https://github.com/bitcoin/bitcoin/issues/20555
18:57 <felixweis> got tor working, was :9150 for some reason
18:57 <hmrawal2008> are there any peers to connect for later testing ?
18:57 <jarolrod> felixweis: are you on windows?
18:57 <emzy> felixweis: that's the port tor-browser is using.
18:57 <felixweis> macos tor brwoser
18:58 <emzy> afaik Port 9150 is the default one of tor browser
18:58 <jonatack> hmrawal2008: you have mainnet tor v3 peers in the guide, and signet ones here in the discussion
18:58 <jarolrod> On making a comment on the issue page: list your hardware and operating system, the rc version you tested, what you were able to test, and what you found while testing
18:58 <hmrawal2008> so will these peers be available for later use also right ?
18:59 <jarolrod> If everything went well, that's great! let us know
18:59 <emzy> I will have mine up for a few weeks.
18:59 <jonatack> (i don't see any tor v3 peers in testnet ATM)
18:59 <felixweis> testnet is just too large for IBD :( signet all the way!
19:00 <jarolrod> That's time everyone!, thanks for participating, happy holidays!
19:00 <jonatack> hmrawal2008: yes, worth trying to connect to them, emzy's mainnet ones are stable and i think the signet ones are stable, too
19:00 <felixweis> thanks jarolrod for hosting :)
19:01 <jarolrod> #endmeeting
19:01 <jonatack> thanks jarolrod, great initiative 🍰
19:01 <jnewbery> thanks jarolrod!
19:01 <ajonas> thanks jarolrod
19:01 <hmrawal2008> cool thanks, thanks jarolrod, thanks everyone and merry christmas
19:01 <fodediop> thank you everyone! happy holidays and happy new year!
19:01 <emzy> thanks jarolrod!
19:01 <heisenberg_hunt> Thanks jarolrod for hosting.... Happy Holidays and Merry Christmas everyone
19:02 <jarolrod> 🎄
19:03 <emzy> Thanks jarolrod for hosting.... Happy Holidays and Merry Christmas everyone. See you 2021.
{% endirc %}
