class Photo
  include Mongoid::Document
  store_in collection: :photo
  field :el_caption
  field :el_categories_1_path
  field :el_categories_2_path
  field :el_categories_3_path
  field :el_categories_4_path
  field :el_categories_5_path
  field :el_categories_6_path
  field :el_categories_7_path
  field :el_comment_status
  field :el_creation_date
  field :el_credit
  field :el_height
  field :el_id
  field :el_one_off_photographer
  field :el_photo
  field :el_photo_type_credit
  field :el_photo_type_id
  field :el_photo_type_name
  field :el_photo_type_slug
  field :el_photographer_first_name
  field :el_photographer_last_name
  field :el_photographer_records_audioclips
  field :el_pub_date
  field :el_reproduction_allowed
  field :el_status
  field :el_user_generated
  field :el_width
  field :wp_sites, type: Array, default: []
  field :used_in, type: Array, default: []
  field :wp_id
  field :computed_bylines, type: Array, default: []

  def bylines
    first_name = el_photographer_first_name || ""
    last_name = el_photographer_last_name || ""

    unless first_name.empty? && last_name.empty?
      [ { :first_name => first_name.strip, :last_name => last_name.strip } ]
    else
      []
    end
  end
end
