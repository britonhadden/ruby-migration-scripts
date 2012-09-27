class MediaEnt
  include Mongoid::Document
  field :path, type: String, default: ""
end
