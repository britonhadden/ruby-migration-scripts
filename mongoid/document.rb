class Document
  include Mongoid::Document
  store_in collection: :document
  field :el_categories_1_path
  field :el_categories_2_path
  field :el_categories_3_path
  field :el_categories_4_path
  field :el_description
  field :el_document
  field :el_document_date
  field :el_id
  field :el_notes
  field :el_originating_site_domain
  field :el_pub_date
  field :el_sites_1_domain
  field :el_slug
  field :el_source
  field :el_thumbnail
  field :el_title
end
