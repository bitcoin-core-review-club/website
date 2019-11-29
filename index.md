---
layout: default
title: home
---
### A weekly review club for Bitcoin Core PRs

<span class="question">What is this?</span> A weekly
club for reviewing Bitcoin Core PRs in the Freenode `#bitcoin-core-pr-reviews`
IRC channel at **18:00 UTC on Wednesdays**.

<span class="question">What's it for?</span> To
help newer contributors learn about the Bitcoin Core review process. Review Club
is *not* primarily intended to help open PRs get merged (although that might be
a nice side-effect).

<span class="question">Who should take part?</span>
Anyone who wants to learn about contributing to Bitcoin Core. All are welcome
to come and ask questions!

<span class="question">What's the benefit for participants?</span> Reviewing
and testing PRs is the best way to start contributing to Bitcoin Core, but it's
difficult to know where to start. There are hundreds of open PRs, many require
a lot of contextual knowledge, and contributors and reviewers often use
unfamiliar terminology. The Review Club will give you the tools and knowledge
you need in order to take part in the Bitcoin Core review process on Github.

<span class="question">How do I take part?</span> To
take part, you should:

1. Clone the [Bitcoin repo](https://github.com/bitcoin/bitcoin), check out and
  build the PR branch and run all tests.
2. Review the code changes and read the comments on the PR.
3. Make a note of any questions you want to ask.
4. Join the Freenode `#bitcoin-core-pr-reviews` IRC channel at **18:00 UTC on Wednesday**.

<span class="question">Who runs this?</span> [jnewbery](https://github.com/jnewbery)
started Review Club and schedules the upcoming meetings. Individual meetings
are hosted by a variety of Bitcoin Core contributors. See some of our [previous
hosts](/meetings-hosts/).

## Upcoming Meetings

{% for post in site.posts reversed %}
  {% capture nowunix %}{{'now' | date: "%s"}}{% endcapture %}
  {% capture posttime %}{{post.date | date: '%s'}}{% endcapture %}
  {% capture components %}
    {%- for comp in post.components -%}
      <a href="/meetings-components/#{{comp}}">{{comp}}</a>{% unless forloop.last %}, {% endunless %}
    {%- endfor -%}
  {% endcapture %}
  {% if posttime >= nowunix %}<div class="home-posts-post">
    <span class="home-posts-post-date">{{ post.date | date_to_string }}</span>
    <span class="home-posts-post-arrow">&raquo;</span>
    <a class="home-posts-post-title" href="{{ post.url }}">#{{ post.pr }} {{ post.title }}</a>
    ({{components}})
    <span class="host">hosted by
      <a class="host" href="/meetings-hosts/#{{post.host}}">{{ post.host }}</a>
    </span>
  </div>{%- endif -%}
{% endfor %}

We're always looking for interesting PRs to discuss in Review Club and for
volunteer hosts to lead the discussion:

- To suggest a PR, please leave a comment on [this github
  issue](https://github.com/bitcoin-core-review-club/bitcoin-core-review-club.github.io/issues/14).
- If you'd like to host a meeting, look at the [information for meeting
  hosts](https://github.com/bitcoin-core-review-club/bitcoin-core-review-club.github.io/blob/master/CONTRIBUTING.md)
  and contact jnewbery on IRC.

## Recent Meetings

{% for post in site.posts limit: 5 %}
  {% capture nowunix %}{{'now' | date: "%s"}}{% endcapture %}
  {% capture posttime %}{{post.date | date: '%s'}}{% endcapture %}
  {% capture components %}
  {%- for comp in post.components -%}
    <a href="/meetings-components/#{{comp}}">{{comp}}</a>{% unless forloop.last %},{% endunless %}
  {%- endfor -%}
  {% endcapture %}
  {% if posttime < nowunix %}<div class="home-posts-post">
    <span class="home-posts-post-date">{{ post.date | date_to_string }}</span>
    <span class="home-posts-post-arrow">&raquo;</span>
    <a class="home-posts-post-title" href="{{ post.url }}">#{{ post.pr }} {{ post.title }}</a>
    ({{components}})
    <span class="host">hosted by <a class="host" href="/meetings-hosts/#{{post.host}}">{{ post.host }}</a></span>
  </div>{%- endif -%}
{% endfor %}

See all [meetings](/meetings/).

## Other Resources for New Contributors

- Read the [Contributing to Bitcoin Core
  Guide](https://github.com/bitcoin/bitcoin/blob/master/contributing.md). This
  will help you understand the process and some of the terminology we use in
  Bitcoin Core.
- Look at the [Good First
  Issues](https://github.com/bitcoin/bitcoin/issues?q=is%3aissue+is%3aopen+label%3a%22good+first+issue%22)
  and [Up For
  Grabs](https://github.com/bitcoin/bitcoin/issues?utf8=%e2%9c%93&q=label%3a%22up+for+grabs%22)
  list.
- Read the [Bitcoin Core Developer and Productivity Tips](https://github.com/bitcoin/bitcoin/blob/master/doc/productivity.md).
- Brush up on your C++. There are [many primers and reference manuals
  available](https://stackoverflow.com/questions/388242/the-definitive-c-book-guide-and-list).
- Read the blog posts on contributing to Bitcoin Core from [Jimmy
  Song](https://bitcointechtalk.com/a-gentle-introduction-to-bitcoin-core-development-fdc95eaee6b8)
  and [John
  Newbery](https://bitcointechtalk.com/contributing-to-bitcoin-core-a-personal-account-35f3a594340b).
