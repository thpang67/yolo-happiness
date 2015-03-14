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

<b>This e-mail is to inform you of a 'push' event.</b>

<h2>Information about request</h2>
<ul>
  <li>Repository : #{repo}</li>
  <li>Action     : #{action}</li>
  <li>Message    : #{message}</li>
  <li>Items      : #{items}</li>
</ul>
MESSAGE_END

  Net::SMTP.start('localhost') do |smtp|
    smtp.send_message message, from, to
  end

end

post '/events' do
  push = JSON.parse(request.body.read)

  puts "#{push['commits']}"
  puts ""

  #
  # NOTE: There may be more than just 1 element. Should really to an .each here.
  #
  if (!push['commits'].empty?)
      # Message from push event.
      message   = push['commits'][0]['message']

      # Author information.
      aname     = push['commits'][0]['author']['name']
      aemail    = push['commits'][0]['author']['email']
      ausername = push['commits'][0]['author']['username']

      # Committer information.
      cname     = push['commits'][0]['committer']['name']
      cemail    = push['commits'][0]['committer']['email']
      cusername = push['commits'][0]['committer']['username']

      # Repository information
      repo      = push['repository']['name']

      items = ""

      # Repository action from 'push'
      # 
      # NOTE: This only really produces output for one commit
      #       need to create a more robust logic here.
      #
      if (!push['commits'][0]['added'].empty?)
        action = "added"
        push['commits'][0]['added'].each do |item|
           items += item + " "
        end
      end

      if (!push['commits'][0]['removed'].empty?)
        action = "removed"
        push['commits'][0]['removed'].each do |item|
           items += item + " "
        end
      end

      if (!push['commits'][0]['modified'].empty?)
        action = "modified"
        push['commits'][0]['modified'].each do |item|
           items += item + " "
        end
      end
 
      # Message from 'push' command
      push_message  = push['commits'][0]['message']

      sendEmail("#{cname} <#{cemail}>", "#{aname} <#{aemail}>",
                repo, action, message, items)
  end
  
  puts ""

end
