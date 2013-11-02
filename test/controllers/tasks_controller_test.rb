require 'test_helper'

describe TasksController do
  describe '#update' do

    let(:task) {create(:task)}

    it 'sets completed datetime when passed' do
      skip 'inc'
    end

    it 'sets complete bool when passed' do
      params = {format: :json, id: task.id, task: {complete:true}}
      
      put 'update', params, format: :json

      task.reload.complete.must_equal true
      task.reload.complete.wont_equal nil
    end
  end
end