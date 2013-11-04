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

    it 'correctly updates rank when with no nonactive tasks in between' do
      task1 = create(:task, rank: 1)
      task2 = create(:task, rank: 30)
      params = {format: :json, id: task1.id, rank: 1, task: {rank: 1}}

      put :update, params
      get :index, format: :json
      response_json = JSON.parse(response.body)

      response_json[1]['id'].must_equal task1.id
    end

    it 'correctly updates rank when with nonactive tasks in between' do
      task1 = create(:task, rank: 1)
      hidden_task1 = create(:task, :complete, updated_at: 10.days.ago, rank: 20)
      task2 = create(:task, rank: 30)
      params = {format: :json, id: task1.id, rank: 1, task: {rank: 1}}

      put :update, params
      get :index, format: :json
      response_json = JSON.parse(response.body)

      response_json.count.must_equal 2
      response_json[1]['id'].must_equal task1.id
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