class TasksController < ApplicationController
  respond_to :json

  def index
    respond_with Task.rank(:rank).all
  end

  def show
    respond_with Task.find(params[:id])
  end

  def create
    respond_with Task.create(params["task"].permit(:name))
  end

  def update
    strong_params = params["task"].permit(:name, :complete)
    respond_with Task.update(params[:id], strong_params)
    Task.find(params[:id]).update(rank_position: params[:rank])
  end

  def destroy
    respond_with Task.destroy(params[:id])
  end
end