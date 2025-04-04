---
layout: default
title: Hosting a Review Club Meeting
---

# Hosting a Bitcoin Core Review Club Meeting

## How to Choose a PR

- The purpose of PR Review Club is to help new contributors learn about the
  Bitcoin Core codebase and the process of contributing to the project. Select a PR
  that is likely to be instructive or interesting. Don't select a PR just because
  you want it to be merged soon! You may even select a PR that is already merged.

- The PR can be complex, but keep in mind that attendees may be at a variety of
  different experience levels. Some attendees have only just cloned the Bitcoin
  Core repo for the first time, and some have been contributing for months or
  years. If you choose a complex PR, try to provide notes that would help a
  beginner get up to speed.

- It's fine to discuss a PR that you opened yourself. After all, you probably
  know more about it than anyone else!

- The appropriate amount of code change to discuss depends on the complexity of
  the code. It might be fine to discuss 10-20 lines of code if the change is
  very subtle or has complex interactions. If the change is more straightforward,
  then it might be fine to discuss 100+ lines of code change. If the PR seems too
  large, consider only discussing a subset of the commits.

- In the past, we have broken up discussion on a PR into multiple meetings, and
  run additional meetings during the week to accommodate higher interest on more
  complex PRs. If you feel additional time is appropriate, don't hesitate to
  propose something!

## Before the Meeting

- Consider contacting the PR author to let them know that you're going to
  talk about their PR in the review club. They'll probably be happy that you're
  interested in their PR and may be prepared to answer questions and give
  you more context. They may even want to join the meeting themselves.

- Post an announcement for your PR as soon as you can - at least 2 weeks before
  the meeting.  See the [Making a New Post](#making-a-new-post) section below
  for how to make an announcement post.

- Post notes and questions 1-2 weeks before the meeting. Again, the earlier, the better!
  That gives attendees time to review the PR and prepare for the meeting; we typically see much
  higher attendance and more lively discussions when attendees have more time to prepare.

- Prepare a range of questions from basic to advanced. The review club is a way
  to help new developers learn. There should be something for everyone.

- In the notes and meeting, don't just talk about the mechanical code changes.
  Other important aspects to consider are:

  - The motivation for the PR.
  - The historical context of the PR (why things in the code are the way they
    are currently, and what PRs have touched that part of the code base in the past).
  - How to review and test the changes.
  - Advantages and disadvantages of this approach compared to alternative approaches.
  - Potential bugs reviewers might want to look out for.
  - Fun C++ things.

- You may want to think about how you want to split the discussion across two
  meetings. Here are some ideas:

  - Conceptual and approach, then implementation.
  - The first n commits of the PR, then the last n commits.

- If you refer to yourself in the notes, use third person narrative
  (e.g. your name or GitHub profile) rather than first person ("I").

- Don't spoon-feed the attendees. Give them pointers for
  where to look in the codebase/GitHub/documentation, and let them do their
  own research from there.

- When linking to code, use stable links that won't break later:

  - for links to code in the master branch, link to a recent commit hash in
    the master branch of bitcoin/bitcoin, e.g.
    [https://github.com/bitcoin/bitcoin/blob/23d3ae7a/src/addrman.cpp#L44](https://github.com/bitcoin/bitcoin/blob/23d3ae7a/src/addrman.cpp#L44).
    You can use a short (8 character) commit id.

    **REASON**: linking directly to master
    isn't stable because line numbers/files change over time.

  - for links to code in the PR branch, ask one of the
    review club maintainers to add a tag of the current PR branch
    to [bitcoin-core-review-club/bitcoin](https://github.com/bitcoin-core-review-club/bitcoin),
    and link to that branch or a commit on that branch, e.g.
    [https://github.com/bitcoin-core-review-club/bitcoin/commit/a6ca5080#diff-be2905e2f5218ecdbe4e55637dac75f3R1751-R1754](https://github.com/bitcoin-core-review-club/bitcoin/commit/a6ca5080#diff-be2905e2f5218ecdbe4e55637dac75f3R1751-R1754).
    You can use a short (8 character) commit id.

    **REASON**: if the PR author modifies
    their branch, links to the PR branch will become invalidated. If they
    force-push and the commits are detached, those commits will eventually be
    removed by GitHub.

- Thorough preparation will really pay off. Taking the time to deeply
  understand the PR will make you feel more relaxed during the meeting.

- If you find yourself struggling with writing the notes and questions, having
  them ready in time, or choosing what areas to focus on, ask the review club
  maintainers for help.

- It can be useful to write out some anticipated answers/links/references
  before the meeting so you don't have to type them in the moment.

#### Making a New Post

[Fork](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks) the website repository [located on GitHub](https://github.com/bitcoin-core-review-club/website).

To make a new post, run the following command from the website directory:

```shell
./contrib/new_post.py <PR_NUMBER> <HOST_GITHUB_USERNAME> <YYYY-MM-DD>
```

This command will create a new markdown file for the post, with metadata and
initial Notes and Questions headers.

For full help on the command, run

```shell
./contrib/new_post.py -h
```

## In the Meeting

- Come with the mindset that the attendees are people who are as smart as you,
  but don't have the context that you do in Bitcoin protocol development or
  the Bitcoin Core codebase.

- Start the meeting with `#startmeeting` and "hi" from everyone so you know
  who's at their keyboard and paying attention.

- It's nice to remind people of some of our meeting conventions at the start:

  - Attendees don't have to ask to ask a question (e.g. "I have a question
    about x but I don't know if it's on-topic?"). They should just go ahead and
    ask. If it's off-topic, the host will say so.

  - The host is there to help moderate, not to lead. Attendees don't need to wait
    for the host to ask a specific question — they can just jump in at any point.

- A quick poll at the start ("Did everyone get a chance to review the PR? How
  about a quick y/n from everyone") establishes who will probably be
  asking/answering the more interesting questions.

- Move quickly at the start of the meeting to get to the interesting parts of
  the PR as soon as possible — preferably within 2 or 3 minutes.

- Don't worry if people haven't had a chance to review the PR yet. This
  is a voluntary meeting and most people have a lot of other commitments.

- Very open questions to the group (e.g. "Does everyone know how tx gossip works
  in Bitcoin?") don't get a good response because all the attendees are waiting for
  someone else to answer. Instead try to make the questions focused on the
  PR or change set that is being reviewed (e.g. "how does commit X change the
  way bitcoind gossips transactions?"). Try to phrase questions positively
  ("please describe how X works") rather than negatively ("Does anyone not know
  how X works?").

- Once the meeting has reached the challenging questions,
  it sometimes feels like there are long stretches of silence and no one
  is out there. Be patient. It takes people a bit of time to formulate their
  thoughts and type them out.

- Be encouraging! For many people, asking questions or volunteering an answer
  can be intimidating, even in the pseudonymous comfort of IRC. People are
  there to learn. Try to create an environment where they feel safe to ask any
  questions and where they can attempt to answer without fear.

- Keep an eye on the clock, and try to wrap up the session with `#endmeeting` at the end of the
  hour. Even if you're happy to continue beyond the hour, some of the attendees
  might have hard stops.

- Have fun, and pat yourself on the back for making Bitcoin protocol development
  stronger and more decentralized 🚀

## After a Meeting

Let one of the review club maintainers know that the meeting is over. They'll
take care of updating the website.

#### Adding logs to the review club website

_This process is done by the review club maintainers_

- Uncomment the `## Meeting Log` markup in the meeting post and copy-paste the
  meeting log into it. Meeting logs should be copied exactly, but an `##
  Erratum` section can be added to correct factual errors.

  - To sanitize logs exported from IRCCloud (ensure UTC timezone is selected
    during export), use the following command on the unzipped .txt file:
    ```sh
    cat \#bitcoin-core-pr-reviews.txt \
      | sed -n '/#startmeeting/h;//!H;$!d;x;//p' \
      | sed '/#endmeeting/q' \
      | sed '/[⇐→]/d' \
      | LC_ALL=C tr -dc '\011\012\015\040-\176\200-\377' \
      | cut -c 13-17,22- \
      > sanitized_log.txt
    ```

- If there won't be any more meetings, change the `status` of the post from `upcoming` to `past`.
  ```diff
  -status: upcoming
  +status: past
  ```

- Add the first 7 characters of the PR commit hash at HEAD to the meeting post.
  This adds a link to the tagged branch on the review club bitcoin core repo.
  ```diff
  -commit:
  +commit: eebaca7
  ```

- Push a tag of the branch at the time of the meeting to the [PR Review Club
  Bitcoin repo](https://github.com/bitcoin-core-review-club/bitcoin). This is so
  if the PR branch changes after the review club meeting, people reading the
  notes and log later can see the branch as it was at the time of the meeting:

  - Run these steps from the root of your local bitcoin repo.

    ```shell
    cd bitcoin
    ```

  - The first time you do this, you'll need to add the review club bitcoin
    repo to your git remotes:

    ```shell
    git remote add review-club git@github.com:bitcoin-core-review-club/bitcoin.git
    ```

  - Push a tag to the review-club remote
    ```shell
    git push review-club <commit hash>:refs/tags/pr<number>  # e.g. git push review-club eebaca7:refs/tags/pr17487
    ```
