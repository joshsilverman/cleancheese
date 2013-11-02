class TasksController < ApplicationController
  respond_to :json

  def index
    show_conditions = "updated_at > ? 
                       OR complete <> true
                       OR complete IS NULL"
    tasks = Task.active.rank(:rank).all
    respond_with tasks
  end

  def show
    respond_with Task.find(params[:id])
  end

  def create
    respond_with Task.create(params["task"].permit(:name))
  end

  def update
    # sanitize params
    strong_params = params["task"].permit(:name, :complete)

    task = Task.find(params[:id])

    #update rank
    task.update(rank_position: params[:rank])

    # update completed_at
    if strong_params[:complete] == true
      task.update(completed_at: task.updated_at) 
    elsif strong_params[:complete] == false
      task.update(completed_at: nil)
    end

    respond_with Task.update(params[:id], strong_params)
  end

  def destroy
    respond_with Task.destroy(params[:id])
  end
end