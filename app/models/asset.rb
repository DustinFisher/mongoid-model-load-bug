class Asset
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user_id, type: Integer

  index({ user_id: 1 })
end
