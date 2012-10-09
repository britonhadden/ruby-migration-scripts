class Story
  @@MAX_NUM_BYLINES = 8 
  @@MAX_NUM_CATEGORIES = 12
  include Mongoid::Document
  store_in collection: :story
  field :el_bylines_1_first_name
  field :el_bylines_1_last_name
  field :el_bylines_1_records_audioclips
  field :el_bylines_2_first_name
  field :el_bylines_2_last_name
  field :el_bylines_2_records_audioclips
  field :el_bylines_3_first_name
  field :el_bylines_3_last_name
  field :el_bylines_3_records_audioclips
  field :el_bylines_4_first_name
  field :el_bylines_4_last_name
  field :el_bylines_4_records_audioclips
  field :el_bylines_5_first_name
  field :el_bylines_5_last_name
  field :el_bylines_5_records_audioclips
  field :el_bylines_6_first_name
  field :el_bylines_6_last_name
  field :el_bylines_6_records_audioclips
  field :el_bylines_7_first_name
  field :el_bylines_7_last_name
  field :el_bylines_7_records_audioclips
  field :el_bylines_8_first_name
  field :el_bylines_8_last_name
  field :el_bylines_8_records_audioclips
  field :el_categories_10_path
  field :el_categories_11_path
  field :el_categories_12_path
  field :el_categories_1_path
  field :el_categories_2_path
  field :el_categories_3_path
  field :el_categories_4_path
  field :el_categories_5_path
  field :el_categories_6_path
  field :el_categories_7_path
  field :el_categories_8_path
  field :el_categories_9_path
  field :el_comment_status
  field :el_dateline_dateline
  field :el_headline
  field :el_id
  field :el_lead_photo_cropped_height
  field :el_lead_photo_cropped_photo
  field :el_lead_photo_cropped_width
  field :el_lead_photo_has_headline
  field :el_lead_photo_id
  field :el_lead_photo_original_caption
  field :el_lead_photo_original_categories_1_path
  field :el_lead_photo_original_categories_2_path
  field :el_lead_photo_original_categories_3_path
  field :el_lead_photo_original_categories_4_path
  field :el_lead_photo_original_categories_5_path
  field :el_lead_photo_original_comment_status
  field :el_lead_photo_original_creation_date
  field :el_lead_photo_original_credit
  field :el_lead_photo_original_height
  field :el_lead_photo_original_id
  field :el_lead_photo_original_one_off_photographer
  field :el_lead_photo_original_photo
  field :el_lead_photo_original_photo_type_credit
  field :el_lead_photo_original_photo_type_id
  field :el_lead_photo_original_photo_type_name
  field :el_lead_photo_original_photo_type_slug
  field :el_lead_photo_original_photographer_first_name
  field :el_lead_photo_original_photographer_last_name
  field :el_lead_photo_original_photographer_records_audioclips
  field :el_lead_photo_original_pub_date
  field :el_lead_photo_original_reproduction_allowed
  field :el_lead_photo_original_status
  field :el_lead_photo_original_user_generated
  field :el_lead_photo_original_width
  field :el_metadata_1_content
  field :el_metadata_1_content_type_name
  field :el_metadata_1_id
  field :el_metadata_1_object_id
  field :el_metadata_1_type_id
  field :el_metadata_1_type_label
  field :el_metadata_1_type_name
  field :el_metadata_2_content
  field :el_metadata_2_content_type_name
  field :el_metadata_2_id
  field :el_metadata_2_object_id
  field :el_metadata_2_type_id
  field :el_metadata_2_type_label
  field :el_metadata_2_type_name
  field :el_one_off_byline
  field :el_post_story_blurb
  field :el_pre_story_blurb
  field :el_print_date
  field :el_print_edition_name
  field :el_print_headline
  field :el_print_page
  field :el_print_section_name
  field :el_pub_date
  field :el_sites_1_domain
  field :el_slug
  field :el_status
  field :el_story
  field :el_subhead
  field :el_tease
  field :el_tease_photo
  field :el_update_date
  field :el_updated
  field :wp_categories, type: Array, default: []
  field :wp_site, type: String, default: "main"
  field :has_inlines, type: Boolean, default: false
  field :computed_bylines, type: Array, default: []
  
  def bylines
    #build an array of bylines calls and then remove all the nils
    (1..@@MAX_NUM_BYLINES).inject([]) { |init,indx| init << get_byline(indx) }.compact
  end

  def get_byline(n)
    #returns an author hash of el_bylines_n_*
    field_prefix = "el_bylines_#{n}_"
    #get the field values at n, setting them to empty if they're not there
    first_name = self.send( field_prefix + "first_name") || ""
    last_name = self.send( field_prefix + "last_name") || ""
    #if bylinenotfound is in there, don't return it
    no_byline = (first_name + last_name).gsub(" ","").downcase.include?("bylinenotfound")

    unless (first_name.empty? && last_name.empty?) || no_byline 
      #remove bad WEEKEND formatting
      first_name.gsub!("// by","")
      last_name.gsub!("// by","")

      { :first_name => first_name.strip, :last_name => last_name.strip }
    else
      nil
    end
  end

  def categories
    out = (1..@@MAX_NUM_CATEGORIES).inject([]) do |init,indx| 
      init <<  self.send( "el_categories_#{indx}_path" )
    end
    out.compact
  end


end
