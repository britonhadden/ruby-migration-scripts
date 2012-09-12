class Embedded
  include Mongoid::Document
  store_in collection: :embedded
  field :el_caption
  field :el_categories_1_path
  field :el_categories_2_path
  field :el_categories_3_path
  field :el_categories_4_path
  field :el_categories_5_path
  field :el_categories_6_path
  field :el_categories_7_path
  field :el_comment_status
  field :el_embedded_object
  field :el_embedded_type_id
  field :el_embedded_type_name
  field :el_embedded_type_slug
  field :el_height
  field :el_id
  field :el_originating_site_domain
  field :el_pub_date
  field :el_sites_1_domain
  field :el_sites_2_domain
  field :el_slug
  field :el_status
  field :el_title
  field :el_width
end
