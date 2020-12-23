---
layout: default
title: home
---
### A weekly review club for Bitcoin Core PRs

<span class="question">What is this?</span> &nbsp;A weekly club for reviewing
Bitcoin Core PRs at **{{ site.meeting_time }} on {{ site.meeting_day }}s** on IRC.

<span class="question">What's it for?</span> &nbsp;To help newer contributors
learn about the Bitcoin Core review process. The review club is *not* primarily
intended to help open PRs get merged (although that might be a nice
side-effect).

<span class="question">Who should take part?</span> &nbsp;Anyone who wants to
learn about contributing to Bitcoin Core. All are welcome to come and ask
questions!

<span class="question">What's the benefit for participants?</span>
&nbsp;Reviewing and testing PRs is the best way to start contributing to Bitcoin
Core, but it's difficult to know where to start. There are hundreds of open PRs,
many require a lot of contextual knowledge, and contributors and reviewers often
use unfamiliar terminology. The review club will give you the tools and
knowledge you need in order to take part in the [Bitcoin Core review
process](https://github.com/bitcoin/bitcoin/blob/master/CONTRIBUTING.md#peer-review)
on GitHub.

<span class="question">How do I take part?</span> Just show up on IRC! See
[Attending your first PR Review Club](/your-first-meeting/) for more tips
on how to participate.

<span class="question">Who runs this?</span> &nbsp;Bitcoin Core contributor
[jnewbery](https://github.com/jnewbery) started the review club and schedules
the upcoming meetings. Individual meetings are hosted by a variety of Bitcoin
Core contributors. See some of our [previous hosts](/meetings-hosts/).

## Upcoming Meetings

🎄 The review club is taking a break for the rest of 2020. We wish everyone a very happy holidays and we'll see you all back at review club on **January 6th**! 🎄

<!--
<table>
{% for post in site.posts reversed %}
  {% capture components %}
  {%- for comp in post.components -%}
    <a href="/meetings-components/#{{comp}}">{{comp}}</a>{% unless forloop.last %}, {% endunless %}
  {%- endfor -%}
  {% endcapture %}
  {% if post.status == "upcoming" %}
    <tr>
      <div class="home-posts-post">
        <td class="Home-posts-post-date">{{ post.date | date_to_string }}</td>
        <td class="Home-posts-post-arrow">&raquo;</td>
        <td><a class="Home-posts-post-title" href="{{ post.url }}">{% if post.pr %}#{{ post.pr }} {% endif %} {{ post.title }}</a>
        ({{components}})
        <span class="host">hosted by
        <a class="host" href="/meetings-hosts/#{{post.host}}">{{ post.host }}</a>
        </span></td>
      </div>
    </tr>
  {%- endif -%}
{% endfor %}
</table>
-->

We're always looking for interesting PRs to discuss in the review club and for
volunteer hosts to lead the discussion:

- To suggest a PR, please leave a comment on [this GitHub
  issue](https://github.com/bitcoin-core-review-club/bitcoin-core-review-club.github.io/issues/14).
- If you'd like to host a meeting, look at the [information for meeting
  hosts](https://github.com/bitcoin-core-review-club/bitcoin-core-review-club.github.io/blob/master/CONTRIBUTING.md)
  and contact jnewbery on IRC.

## Recent Meetings

<table>
{% assign count = 0 %}
{% for post in site.posts %}
  {% capture components %}
  {%- for comp in post.components -%}
    <a href="/meetings-components/#{{comp}}">{{comp}}</a>{% unless forloop.last %},{% endunless %}
  {%- endfor -%}
  {% endcapture %}
  {% if post.status == "past" %}
    {% assign count = count | plus: 1 %}
    <tr>
      <div class="home-posts-post">
        <td class="Home-posts-post-date">{{ post.date | date_to_string }}</td>
        <td class="Home-posts-post-arrow">&raquo;</td>
        <td><a class="Home-posts-post-title" href="{{ post.url }}">{% if post.pr %}#{{ post.pr }}{% endif %} {{ post.title }}</a>
        ({{components}})
        <span class="host">hosted by <a class="host" href="/meetings-hosts/#{{post.host}}">{{ post.host }}</a></span></td>
      </div>
    </tr>
  {%- endif -%}
  {% if count == 4 %}
    {% break %}
  {% endif %}
{% endfor %}
</table>

See all [meetings](/meetings/).

## Other Resources for New Contributors

- Read the [Contributing to Bitcoin Core
  Guide](https://github.com/bitcoin/bitcoin/blob/master/CONTRIBUTING.md). This
  will help you understand the process and some of the terminology we use in
  Bitcoin Core.
- Look at the [Good First
  Issues](https://github.com/bitcoin/bitcoin/issues?q=is%3aissue+is%3aopen+label%3a%22good+first+issue%22)
  and [Up For
  Grabs](https://github.com/bitcoin/bitcoin/issues?utf8=%e2%9c%93&q=label%3a%22up+for+grabs%22)
  list.
- Read the Bitcoin Core [Developer
  Notes](https://github.com/bitcoin/bitcoin/blob/master/doc/developer-notes.md)
  and [Productivity
  Tips](https://github.com/bitcoin/bitcoin/blob/master/doc/productivity.md).
- Brush up on your C++. There are [many primers and reference manuals
  available](https://stackoverflow.com/questions/388242/the-definitive-c-book-guide-and-list).
- There are some excellent blog posts on how to start contributing to Bitcoin Core:
    - [A Gentle Introduction to Bitcoin Core Development (Jimmy Song)](https://bitcointechtalk.com/a-gentle-introduction-to-bitcoin-core-development-fdc95eaee6b8)
    - [Contributing to Bitcoin Core - a Personal Account (John Newbery)](https://bitcointechtalk.com/contributing-to-bitcoin-core-a-personal-account-35f3a594340b)
    - [Onboarding to Bitcoin Core (Amiti Uttarwar)](https://medium.com/@amitiu/onboarding-to-bitcoin-core-7c1a83b20365)
    - [How to Review Pull Requests in Bitcoin Core (Jon Atack)](https://jonatack.github.io/articles/how-to-review-pull-requests-in-bitcoin-core)
