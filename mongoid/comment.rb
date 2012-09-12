class Comment
  include Mongoid::Document
  store_in collection: :comment
  field :el_comment
  field :el_content_type_name
  field :el_id
  field :el_ip_address
  field :el_is_public
  field :el_is_removed
  field :el_object_pk
  field :el_site_domain
  field :el_submit_date
  field :el_user_email
  field :el_user_name
  field :el_user_url
end
