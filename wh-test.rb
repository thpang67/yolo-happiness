#
# Ruby file that takes the webhook information from GitHub and sends
# back the command executed along with a few other bits. It will
# parse the JSON item returned.
#
# NOTE: What is my email?
#

# required modules
require 'sinatra'
require 'json'

# Parse push event
post '/events' do
  push = JSON.parse(request.body.read)

  # Repository information
  repo      = push['repository']['name']

  #
  # cycle through all items found as there may be more than
  # one, add, remove, update, etc.
  #
  # for commit in push['commits']
  # push['commits'].each do |commit|
  # size = push['commits'].size
  # puts "Array size: #{size}"

  commits = push['commits']
  # commits.each do |commit|
  #     puts commit
  # end

  # Test what is coming back in commits
  if (commits.kind_of?(Array))
    puts "Array!!"
    begin
      commits.each do |commit|
        puts "Commit: #{commit}"
      end
    rescue
      puts "Something went wrong processing our commit statement."
    else
      puts "It worked!!"
    end
  elsif (commits.kind_of?(Hash))
    puts "Hash!!"
  elsif (commits.kind_of?(Object))
    puts "Object!!"
  end

=begin

      # puts "#{commit}"
      # Message from push event.
      message   = commit['message']

      # Author information.
      aname     = commit['author']['name']
      aemail    = commit['author']['email']
      ausername = commit['author']['username']

      # Committer information.
      cname     = commit['committer']['name']
      cemail    = commit['committer']['email']
      cusername = commit['committer']['username']

      # Repository action from 'push'
      actions = ['added', 'removed', 'modified']
      actions.each do |raction|
          puts "#{raction}"
          if (!commit[raction].empty?)
              puts "Action: #{raction}"
              commit[raction].each do |item|
                if (items.size > 0)
                   items += ", " + item
                else
                   items = item
                end
              end

              sendEmail("#{cname} <#{cemail}>", "#{aname} <#{aemail}>",
                        repo, raction, message, items)
          end
      end

      puts "Repo            : #{repo}"
      puts "Message         : #{message}"
      puts "Author - Name   : #{aname}"
      puts "Author - e-mail : #{aemail}"
  end

=end

end
