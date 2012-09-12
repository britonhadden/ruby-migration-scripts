class User
  include Mongoid::Document
  store_in collection: :user
  field :el_date_joined
  field :el_email
  field :el_first_name
  field :el_groups_1_name
  field :el_groups_2_name
  field :el_id
  field :el_is_active
  field :el_is_staff
  field :el_is_superuser
  field :el_last_login
  field :el_last_name
  field :el_password
  field :el_username
end
