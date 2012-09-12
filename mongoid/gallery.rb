class Gallery
  include Mongoid::Document
  store_in collection: :gallery
  field :el_blurb
  field :el_categories_1_path
  field :el_categories_2_path
  field :el_categories_3_path
  field :el_categories_4_path
  field :el_comment_status
  field :el_creation_date
  field :el_id
  field :el_is_static
  field :el_mp3_credit
  field :el_mp3_link
  field :el_mp3_url
  field :el_name
  field :el_originating_site_domain
  field :el_sites_1_domain
  field :el_slug
  field :el_status
  field :el_template_prefix
end
