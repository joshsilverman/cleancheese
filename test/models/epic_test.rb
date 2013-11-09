require 'test_helper'

describe Epic do
  describe '#has_many :tasks' do
    it 'is valid with associated tasks' do
      epic = Epic.new
      task = Task.new
      epic.tasks << task

      epic.valid?.must_equal true
    end
  end
end
