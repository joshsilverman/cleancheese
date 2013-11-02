require 'test_helper'

describe TasksController do
  describe '#update' do

    let(:task) {create(:task)}

    it 'sets complete/completed_at when complete passed' do
      params = {format: :json, id: task.id, task: {complete:true}}
      
      put :update, params, format: :json

      task.reload.complete.must_equal true
      task.reload.complete.wont_equal nil
      task.reload.complete.wont_equal nil
    end
  end

  describe '#index' do
    it 'returns tasks' do
      task = create(:task, complete:nil)

      get :index, {format: :json}
      response_json = JSON.parse(response.body)

      response_json.count.must_equal 1
      response_json.first['id'].must_equal task.id
    end
  end
end