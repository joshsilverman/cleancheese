require 'test_helper'

describe Epic do
  describe '#has_many :tasks' do
    it 'is valid with associated tasks' do
      epic = Epic.new
      user = User.new
      epic.user = user
      
      task = Task.new
      epic.tasks << task

      epic.valid?.must_equal true
    end
  end

  describe '#belongs_to :user' do
    it 'is valid with associated user' do
      epic = Epic.new
      user = User.new
      epic.user = user

      epic.valid?.must_equal true
    end

    it 'is not valid without associated user' do
      epic = Epic.new

      epic.valid?.must_equal false
    end
  end
end
