#
# Ruby file that takes the webhook information from GitHub and sends
# back the command executed along with a few other bits. It will
# parse the JSON item returned.
#
# NOTE: What is my email please tell me?
#

# required modules
require 'sinatra'
require 'json'
require 'net/smtp'

# 
def sendEmail(from, to, repo, action, result)
    
    # variables
    @repo   = repo
    @action = action
    @result = result
    
    message << MESSAGE_END
From: #{from}
To: #{to}
Subject: #{repo} action: #{action}

This email is to inform you of the following:

Repository : #{repo}
Action     : #{action}
Result     : #{result}
MESSAGE_END

end

post '/github/payload' do
    push = JSON.parse(request.body.head)
end
