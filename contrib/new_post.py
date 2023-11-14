#!/usr/bin/env python3
"""Create a new post."""
import argparse
from dataclasses import dataclass
import datetime
import json
import os
import sys
import sys
import urllib.request

MIN_PYTHON = (3, 9)

# These correspond to the GitHub labels used by Bitcoin Core.
DESIRED_COMPONENTS = [
  'Block storage',
  'Build system',
  'Consensus',
  'Data corruption',
  'Descriptors',
  'Docs',
  'GUI',
  'Interfaces',
  'Mempool',
  'Mining',
  'P2P',
  'Privacy',
  'PSBT',
  'Refactoring',
  'Resource usage',
  'RPC/REST/ZMQ',
  'Scripts and tools',
  'Settings',
  'Tests',
  'TX fees and policy',
  'Utils/log/libs',
  'UTXO Db and Indexes',
  'Validation',
  'Wallet',
]
COMPONENTS = list(map(lambda x: x.lower(), DESIRED_COMPONENTS))

# Some PRs contain undesired words (here, single characters) immediately after
# the prefix. Add the characters or words here to strip them from the title.
UNDESIRED_PR_TITLE_WORDS = ['-', '_']

GITHUB_API_URL = 'https://api.github.com/repos/bitcoin/bitcoin/pulls'

@dataclass
class PullRequest():
    number: int
    title: str
    labels: list[str]
    user: str

def validate_date(date_in: str) -> str:
    """Normalizes data from any recognised iso format into YYYY-MM-DD"""
    date = datetime.date.fromisoformat(date_in)
    return date.isoformat()

def clean_title(title: str) -> str:
    """Normalizes the title formatting"""
    words = title.split()

    # Remove prefixes and unwanted characters from the beginning of the title
    for word in words:
        if (word in UNDESIRED_PR_TITLE_WORDS
                or word.endswith(':')  # usually a component prefix
                or (word.startswith('[') and word.endswith(']'))):  # usually a component prefix
            words.pop(0)
        else:
            # Continue as soon as we've found an allowed word
            break

    # Capitalize the first word
    words[0] = words[0].capitalize()

    # Return enclosed in double quotes after joining words and removing any double quotes.
    title = " ".join(words).replace("\"", "")
    return f"\"{title}\""

def valid_components(labels: list[str]) -> list[str]:
    return [l for l in labels if l in COMPONENTS]

def invalid_components(labels: list[str]) -> list[str]:
    return [l for l in labels if l not in COMPONENTS]

def get_nonempty_components(labels: list[str]) -> list[str]:
    # Parses the GitHub labels, and requires user input if no valid components were found
    components = valid_components(labels)
    if components:
        return components

    print(f"No label assigned to the PR yet; you will need to add one or more (comma-separated) manually from {COMPONENTS}")
    while True:
        components_input = input().replace("\'\"", '').split(',')
        components_input = [c.strip().lower() for c in components_input]

        if (invalid := invalid_components(components_input)):
            print(f"Components {invalid} are invalid, please try again")
            continue

        return components_input

def create_post_file(fname: str, pr: PullRequest, date: str, host: str) -> None:
    title = clean_title(pr.title)
    labels = [l.lower() for l in pr.labels]
    components = get_nonempty_components(labels)

    print(f"GitHub PR title: \"{pr.title}\"")
    print(f"Parsed PR title: {title}")
    print(f"GitHub PR labels: \"{labels}\"")
    print(f"Parsed PR labels: \"{components}\"")

    with open(fname, 'w') as f:
        f.write('---\n')
        f.write('layout: pr\n')
        f.write(f"date: {date}\n")
        f.write(f"title: {title}\n")
        f.write(f"pr: {pr.number}\n")
        f.write(f"authors: [{pr.user}]\n")
        f.write(f"components: {json.dumps(components)}\n")  # Use json.dumps() for double quotes
        f.write(f"host: {host}\n")
        f.write("status: upcoming\n")
        f.write("commit:\n")
        f.write("---\n\n")
        f.write("_Notes and questions to follow soon!_\n\n")
        f.write("<!-- TODO: Before meeting, add notes and questions\n")
        f.write("## Notes\n\n\n\n")
        f.write("## Questions\n\n")
        f.write("1. Did you review the PR? [Concept ACK, approach ACK, tested ACK, or NACK](https://github.com/bitcoin/bitcoin/blob/master/CONTRIBUTING.md#peer-review)? What was your review approach?\n")
        f.write("-->\n\n\n")
        f.write("<!-- TODO: After a meeting, uncomment and add meeting log between the irc tags\n")
        f.write("## Meeting Log\n\n")
        f.write("### Meeting 1\n\n")
        f.write("{% irc %}\n")
        f.write("-->\n")
        f.write("<!-- TODO: For additional meetings, add the logs to the same irc block. This ensures line numbers keep increasing, avoiding hyperlink conflicts for identical line numbers across meetings.\n\n")
        f.write("### Meeting 2\n\n")
        f.write("-->\n")
        f.write("{% endirc %}\n")

def load_pr_from_gh(n: int) -> PullRequest:
    response = urllib.request.urlopen(f"{GITHUB_API_URL}/{n}")
    data = json.loads(response.read())
    try:
        return PullRequest(number=data['number'],
                           title=data['title'],
                           labels=[l['name'] for l in data['labels']],
                           user=data['user']['login'])
    except KeyError:
        raise KeyError(f"Could not deserialize GitHub response into PullRequest ({data}")

def main() -> None:

    if sys.version_info < MIN_PYTHON:
        print(f"Error: This script requires Python {'.'.join(map(str, MIN_PYTHON))} or higher.", file=sys.stderr)
        sys.exit(1)

    parser = argparse.ArgumentParser()

    parser.add_argument("-p", "--pr", required=True, type=int, help="PR number (required)")
    parser.add_argument("-u", "--host", required=True, help="Host's github username (required)")
    parser.add_argument("-d", "--date", required=True,  help="Meeting date in YYYY-DD-MM format (required)",
                        type=validate_date)

    args = parser.parse_args()

    # Check file doesn't already exist
    fname = f"_posts/{args.date}-#{args.pr}.md"
    if os.path.isfile(fname):
        sys.exit(f"file {fname} already exists!")

    # Query github api for PR information
    try:
        pr = load_pr_from_gh(args.pr)
    except Exception as e:
        sys.exit(f"Github returned error {e}")

    # Create a new post file if none exists, otherwise exit.
    create_post_file(fname, pr, args.date, args.host)

if __name__ == "__main__":
    main()
