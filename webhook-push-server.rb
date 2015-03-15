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

    # HTML message to send
    email = <<EMAIL_END
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
EMAIL_END

    # Send email to localhost with server running.
    Net::SMTP.start('localhost') do |smtp|
      smtp.send_message email, from, to
    end

end

# Parse push event
post '/events' do
  push = JSON.parse(request.body.read)

  # puts "#{push['commits']}"

  # Repository information
  repo      = push['repository']['name']

  #
  # cycle through all items found as there may be more than
  # one, add, remove, update, etc.
  #
  # for commit in push['commits']
  begin
	  push['commits'].each do |commit|
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
              items = ""
	      actions = ['added', 'removed', 'modified']
	      actions.each do |action|

                  if (!commit[action].empty?)
		      puts "#{action}"
                      puts "#{commit[action]}"

		      commit[action].each do |item|
		          if (items.size > 0)
                              items += ", " + item
                          else
                              items = item
                          end
                      end

                      puts "Sending email for #{action}"
                      sendEmail("#{cname} <#{cemail}>", "#{aname} <#{aemail}>",
                                repo, action, message, items)
                  end

                  items = ""
              end
	  end
  rescue
      puts "Issue with commit: #{commit}"
  else
      puts "It worked!!"
  end
end
