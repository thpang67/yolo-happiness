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
require 'net/smtp'
require 'octokit'

def sendEmail(from, to, repo, action, message, items)
    
    # variables
    @from    = from
    @to      = to
    @repo    = repo
    @action  = action
    @message = message
    @items   = items
    
    message = <<MESSAGE_END
From: #{from}
To: #{to}
MIME-Version: 1.0
Content-type: text/html
Subject: Push request for : #{repo} with action: #{action}

<h2>This e-mail is to inform you of a 'push' event.</h2>

<h3>Information about request</h3>
<ul>
  <li>Repository : <code>#{repo}</code></li>
  <li>Action     : <code>#{action}</code></li>
  <li>Message    : <code>#{message}</code></li>
  <li>Items      : <code>#{items}</code></li>
</ul>
MESSAGE_END

  Net::SMTP.start('localhost') do |smtp|
    smtp.send_message message, from, to
  end

end

# Parse push event
post '/events' do
  push = JSON.parse(request.body.read)

  puts "#{push['commits']}"
  puts ""

  push['commits'].each do |commit|
    puts "#{commit}"
  end

  #
  # NOTE: There may be more than just 1 element. Should really to an .each here.
  #
  push['commits'].each do |commit|
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

      # Repository information
      repo      = push['repository']['name']

      items = ""

      # Repository action from 'push'
      # 
      # NOTE: This only really produces output for one commit
      #       need to create a more robust logic here.
      #
      if (!commit['added'].empty?)
        action = "added"
        commit['added'].each do |item|
           if (items.size > 0)
             items += ", " + item
           else
             items = item
           end
        end
      end

      if (!commit['removed'].empty?)
        action = "removed"
        commit['removed'].each do |item|
           if (items.size > 0)
             items += ", " + item
           else
             items = item
           end
        end
      end

      if (!commit['modified'].empty?)
        action = "modified"
        commit['modified'].each do |item|
           if (items.size > 0)
             items += ", " + item
           else
             items = item
           end
        end
      end
 
      # Message from 'push' command
      push_message  = commit['message']

      sendEmail("#{cname} <#{cemail}>", "#{aname} <#{aemail}>",
                repo, action, message, items)
  end
  
  puts ""

end
