class Vote < ActiveRecord::Base
  belongs_to :suggestion
  belongs_to :story
  belongs_to :user
end
