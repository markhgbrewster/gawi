class AdminWard < ActiveRecord::Base
  has_one :twitter_account, foreign_key: :neighbourhood_id, primary_key: :neighbourhood_code
end