class EpicsController < ApplicationController
  respond_to :json

  def index
    epics = Epic.all
    json = epics.to_json
    render json: json
  end
end