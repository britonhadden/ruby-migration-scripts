class WPUser
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: :wp_user

  field :true_user #is this a real user or is it being generated?
  field :user_login
  field :el_id, default: 0 
  field :wp_id, default: 0 #the wordpress id assigned to this record
  field :first_name
  field :last_name
  field :legacy_password
  field :user_registered
  field :user_email

end
