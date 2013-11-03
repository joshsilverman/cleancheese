require 'test_helper'

describe Task do

  describe '#belongs_to :post' do
    let(:post) {build(:post)}
    let(:task) {build(:task)}

    it 'is valid with associated post' do
      task.valid?.must_equal true
    end

    it 'is valid without associated post' do
      task.post = post

      task.post.wont_be_nil
      task.valid?.must_equal true
    end
  end

  describe '.active' do

    it 'includes incomplete task' do
      task = create(:task, complete:nil)

      tasks = Task.active.to_a

      tasks.count.must_equal 1
      tasks.first.id.must_equal task.id
    end

    it 'includes old incomplete task' do
      task = create(:task, 
                      complete:nil, 
                      created_at: 1.month.ago,
                      updated_at: 1.month.ago)
      
      tasks = Task.active.to_a

      tasks.count.must_equal 1
      tasks.first.id.must_equal task.id
    end

    it 'inclues new complete task' do
      task = create(:task, complete:true)
      
      tasks = Task.active.to_a

      tasks.count.must_equal 1
      tasks.first.id.must_equal task.id
    end

    it 'excludes old complete task' do
      task = create(:task, 
                      complete:true, 
                      created_at: 1.month.ago,
                      updated_at: 1.month.ago)
      
      tasks = Task.active.to_a

      tasks.count.must_equal 0
    end
  end
end
