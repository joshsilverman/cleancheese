def init
  Rails.env.stubs(:test?).returns true
  Rails.logger.level = 1
end

def respond text
  coach = Coach.find(1)
  user = User.find(2)
  
  incoming_message = Post.save_sms user, coach, text, nil
  response = coach.respond user, incoming_message

  if response
    response.text.split("\n").map { |l| puts "> #{l}" } 
  else
    print '> '
    print 'I couldn\'t interpret that. :/'
  end
end

def repl
  puts ''
  print '> '
  input = gets.chomp
  respond input
  repl
end

init
repl