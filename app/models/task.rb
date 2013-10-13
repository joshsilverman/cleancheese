class Task < ActiveRecord::Base
  include RankedModel
  ranks :rank
end