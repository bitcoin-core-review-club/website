# frozen_string_literal: true

# To display all the available rake (Ruby make) tasks, run:
#   rake -T

require 'date'
require 'json'
require 'net/http'
require 'optparse'
require 'rake/testtask'

# To run all tests:
#   rake (or) rake test
#
# To run one test file:
#   rake test TEST=test/FILENAME
#
# To run an individual test in a test file:
#   rake test TEST=test/FILENAME TESTOPTS=--name=TEST_NAME
#
desc 'Run all tests with `rake` or `rake test`'
task default: :test # Make test runner the default rake task.
Rake::TestTask.new do |task|
  task.pattern = 'test/test_*.rb'
end

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
].freeze
COMPONENTS = DESIRED_COMPONENTS.map(&:downcase).freeze

# Some PRs contain undesired words (here, single characters) immediately after
# the prefix. Run `rake -- posts:new --host username --pr 16729` for an example.
# Characters or words we want removed after the prefix can go into this array.
UNDESIRED_PR_TITLE_WORDS = %w(- _).freeze

GITHUB_API_URL = 'https://api.github.com/repos/bitcoin/bitcoin/pulls'
HTTP_SUCCESS  = '200'
HTTP_NOTFOUND = '404'
HTTP_ERRORS = [
  JSON::ParserError,
  SocketError,
  EOFError,
  IOError,
  Errno::ECONNRESET,
  Errno::EINVAL,
  Net::HTTPBadResponse,
  Net::HTTPHeaderSyntaxError,
  Net::ProtocolError,
  Timeout::Error
].freeze

# To see the rake posts:new help, run:
#   rake posts:new -- -H
#
desc 'Create a new post file'
namespace :posts do
  task :new do
    # Fetch user command line args. Exit if required args are missing.
    pr, host, date = get_cli_options_posts
    handle_missing_required_arg('pr') unless pr
    handle_missing_required_arg('host') unless host

    # Ensure PR contains only numerical characters.
    unless pr.size == pr.gsub(/[^0-9-]/i, '').size
      puts "Error: Non-numerical PR #{pr} received. Nothing done, exiting."
      exit
    end

    # Set default value for meeting date if not supplied by user.
    unless date
      date = next_wednesday.to_s
      puts "Date set to next Wednesday: #{date}"
    end

    # Ensure meeting date is valid.
    unless valid_iso8601_date?(date)
      puts "Error: Invalid date (#{date} received, YYYY-MM-DD needed). Nothing done, exiting."
      exit
    end

    # Fetch pull request data from the GitHub v3 REST API.
    http = Net::HTTP.get_response(URI("#{GITHUB_API_URL}/#{pr}"))
    response = parse_response(http, pr)

    # Create a new post file if none exists, otherwise exit.
    filename = "#{'_posts/' if File.directory?('_posts')}#{date}-##{pr}.md"

    if File.file?(filename)
      puts "Filename #{filename} already exists. Nothing done, exiting."
    else
      create_post_file!(filename, response, date, host)
      puts "New file #{filename} created successfully."
    end
    exit
  end
end

def get_cli_options_posts(options = {})
  OptionParser.new do |opts|
    opts.banner = 'Usage: rake posts:new -- <options>'
    opts.on('-p', '--pr NUMBER', 'Pull request number (required)') do
      |pr| options[:pr] = pr
    end
    opts.on('-h', '--host USERNAME', "Host's GitHub username (required)") do
      |host| options[:host] = host
    end
    opts.on('-d', '--date YYYY-MM-DD',
            'Meeting date in ISO8601 format (optional, defaults to next Wednesday)') do
      |date| options[:date] = date
    end
    opts.on('-H', '--help', 'Display this help') do
      puts opts
      exit
    end
    args = opts.order!(ARGV) {}
    opts.parse!(args)
  end
  [options[:pr], options[:host], options[:date]]
end

# To see the rake topics:new help, run:
#   rake topics:new -- -H
#
desc 'Create a new topics file'
namespace :topics do
  task :new do
    # Fetch user command line args. Exit if required args are missing.
    title, slug = get_cli_options_topics
    
    handle_missing_required_arg('title', 'topics') unless title

    # Slugify title if slug not supplied by user.
    unless slug
      slug = title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
      puts "Topic '#{title}' has been slugified and filename set to : #{slug}"
    end
    # Create a new topic file if none exists, otherwise exit.
    filename = "#{'_topics/' if File.directory?('_topics')}#{slug}.md"

    if File.file?(filename)
      puts "Filename #{filename} already exists. Nothing done, exiting."
    else
      create_topic_file!(filename, title)
      puts "New file #{filename} created successfully."
    end
    exit
  end
end

def get_cli_options_topics(options = {})
  OptionParser.new do |opts|
    opts.banner = 'Usage: rake topics:new -- <options>'
    opts.on('-t', '--title TOPIC_LONG', 'Long name for topic (required)') do
      |title| options[:title] = title
    end
    opts.on('-s', '--slug TOPIC_SHORT',
            'Short name for topic (optional, defaults to slugified title)') do
      |slug| options[:slug] = slug
    end
    opts.on('-H', '--help', 'Display this help') do
      puts opts
      exit
    end
    args = opts.order!(ARGV) {}
    opts.parse!(args)
  end
  [options[:title], options[:slug]]
end

def handle_missing_required_arg(name, rake = "posts")
  puts "Error: Missing required --#{name} argument. Run `rake #{rake}:new -- --help` for info."
  exit
end

def valid_iso8601_date?(date_string)
  yyyy, mm, dd = date_string.split('-').map(&:to_i)

  date_string.size == date_string.gsub(/[^0-9-]/i, '').size &&
    [yyyy, mm, dd].none?(nil) && [yyyy, mm, dd].none?(0) &&
    yyyy >= Date.today.year && Date.valid_date?(yyyy, mm, dd)
end

def next_wednesday(date = Date.today, wednesday = 3)
  date + ((wednesday - date.wday) % 7)
end

def parse_response(http, pr)
  code, msg, body = http.code, http.message, http.body

  if code == HTTP_SUCCESS
    JSON.parse(body)
  else
    puts "Error: HTTP #{code} #{msg}#{". PR #{pr} doesn't exist" if code == HTTP_NOTFOUND}."
    exit
  end
rescue *HTTP_ERRORS => e
  "Error #{e.inspect}"
end

def get_nonempty_components(gh_labels)
  # Parses the GitHub labels, and requires user input if no valid components were found
  components = parse_valid_components(gh_labels)
  if components.empty?
    puts "No label assigned to the PR yet; you will need to add one or more (comma-separated) manually from #{COMPONENTS}"
    while true
      components_input = gets.gsub(/['"]/, '').split(',').map(&:strip).map(&:downcase).uniq
      if (components_input - COMPONENTS).empty?
        break
      end
      puts "Components #{components_input - COMPONENTS} are invalid, please try again"
    end
    components = components_input
  end
  return components
end

def create_post_file!(filename, response, date, host)
  title = parse_title(response['title'])
  components = get_nonempty_components(response['labels'])

  puts "GitHub PR title:  \"#{response['title']}\""
  puts "Parsed PR title:  #{title}"
  puts "GitHub PR labels: \"#{parse_components(response['labels']).join(', ')}\""
  puts "Parsed PR labels: \"#{components.join(', ')}\""

  File.open(filename, 'w') do |line|
    line.puts '---'
    line.puts 'layout: pr'
    line.puts "date: #{date}"
    line.puts "title: #{title}"
    line.puts "pr: #{response['number']}"
    line.puts "authors: [#{response.dig('user', 'login')}]"
    line.puts "components: #{components}"
    line.puts "host: #{host}"
    line.puts "status: upcoming"
    line.puts "commit:"
    line.puts "---\n\n"
    line.puts "_Notes and questions to follow soon!_\n\n"
    line.puts "<!-- TODO: Before meeting, add notes and questions"
    line.puts "## Notes\n\n"
    line.puts "## Questions"
    line.puts "1. Did you review the PR? [Concept ACK, approach ACK, tested ACK, or NACK](https://github.com/bitcoin/bitcoin/blob/master/CONTRIBUTING.md#peer-review)? What was your review approach?"
    line.puts "-->\n\n\n"
    line.puts "<!-- TODO: After meeting, uncomment and add meeting log between the irc tags"
    line.puts "## Meeting Log\n\n"
    line.puts "{% irc %}"
    line.puts "{% endirc %}"
    line.puts "-->"
  end
end

def create_topic_file!(filename, title)
  def comment_out(line, header)
    line.puts "<!-- uncomment to add"
    line.puts "## #{header}"
    line.puts "-->"
  end

  File.open(filename, 'w') do |line|
    line.puts '---'
    line.puts 'layout: topic'
    line.puts "title: #{title}"
    line.puts "---\n\n"
    comment_out(line, "Notes")
    comment_out(line, "History")
    comment_out(line, "Resources")
  end
end

def parse_title(title)
  first, *rest = title.split # e.g. if title = "a b c", first = "a", rest = ["b", "c"]
  first.downcase! # mutate first word to lowercase in place
  rest.shift if UNDESIRED_PR_TITLE_WORDS.include?(rest[0]) # rm 1st word if undesired
  prefix = first.gsub(/[:\[\]]/, '') # prefix is first word stripped of :[] chars

  # If prefix is different from first word and is a component, drop first word.
  words = if first != prefix && is_a_component?(prefix)
            [rest.first&.capitalize] + rest[1..-1]
          else
            [first&.capitalize] + rest
          end
  # Return enclosed in double quotes after joining words and removing any double quotes.
  "\"#{words.join(' ').gsub(/"/,  '')}\""
end

def is_a_component?(prefix)
  # Boolean indicating whether `prefix` (without any final "s") is a component.
  # Iterates through the COMPONENTS array and exits with true at the first
  # instance where `prefix` is a substring of the component; otherwise false.
  COMPONENTS.any? { |component| component.include?(prefix.chomp('s')) }
end

def parse_components(labels)
  (labels.map { |label| label['name'].downcase })
end

def parse_valid_components(labels)
  parse_components(labels) & COMPONENTS
end
