require "mocha/setup"

def init
  Rails.env.stubs(:test?).returns true
  Rails.logger.level = 1
end

def respond text
  coach = Coach.find(1)
  user = User.find(2)
  
  incoming_message = Post.save_sms user, coach, text, nil
  response = coach.respond user, incoming_message

  puts ''
  if response
    response.text.split("\n").each_with_index do |l, i| 
      if i == 0
        puts "coach >  #{l}"
      else
        puts "      >  #{l}"
      end
    end
  else
    puts 'coach >  I couldn\'t interpret that. :/'
  end
end

def repl
  puts ''
  print 'you   >  '
  input = gets.chomp

  unless input == 'exit'
    reload!;
    respond input 
    repl
  end
end

init
repl
