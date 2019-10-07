# frozen_string_literal: true

require 'date'
require 'json'
require 'net/http'
require 'optparse'

UNDESIRED_LABELS = [
  'refactoring', 'needs conceptual review', 'needs rebase', 'waiting for author'
].freeze
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

desc 'Create a new post file'
namespace :posts do
  task :new do
    # Fetch user command line args. Exit if required args are missing.
    pr, host, date = get_cli_options
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

def get_cli_options(options = {})
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

def handle_missing_required_arg(name)
  puts "Error: Missing required --#{name} argument. Run `rake posts:new -- --help` for info."
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

def create_post_file!(filename, response, date, host)
  File.open(filename, 'w') do |line|
    line.puts '---'
    line.puts 'layout: pr'
    line.puts "date: #{date}"
    line.puts "title: \"#{response['title']}\""
    line.puts "pr: #{response['number']}"
    line.puts "authors: [#{response.dig('user', 'login')}]"
    line.puts "components: #{parse_components(response['labels'])}"
    line.puts "host: #{host}"
    line.puts "---\n\n"
    line.puts "## Notes\n\n"
    line.puts "## Questions\n"
  end
end

def parse_components(labels)
  (labels.map { |label| label['name'].downcase }) - UNDESIRED_LABELS
end
