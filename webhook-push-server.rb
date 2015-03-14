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

# send email from committer -> author
def sendEmail(from, to, repo, action, message, items)
    
    # variables
    @from    = from
    @to      = to
    @repo    = repo
    @action  = action
    @message = message
    @items   = items
    
    # HTML message to send
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

    # Send email to localhost with server running.
    Net::SMTP.start('localhost') do |smtp|
      smtp.send_message message, from, to
    end

end

# Parse push event
post '/events' do
  push = JSON.parse(request.body.read)

  #
  # cycle through all items found as there may be more than
  # one, add, remove, update, etc.
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
      actions = ['added', 'removed', 'modified']
      actions.each do |raction|
          if (!commit[raction].empty?)
              action = "#{raction}"
              commit[raction].each do |item|
                if (items.size > 0)
                   items += ", " + item
                else
                     items = item
                end
              end

              # Message from 'push' command
              push_message  = commit['message']

              sendEmail("#{cname} <#{cemail}>", "#{aname} <#{aemail}>",
                        repo, action, message, items)
          end
      end
  end
end
