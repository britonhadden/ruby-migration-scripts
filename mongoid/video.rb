class Video
  @@MAX_NUM_CATEGORIES = 9
  include Mongoid::Document
  store_in collection: :video
  field :el_caption
  field :el_categories_1_path
  field :el_categories_2_path
  field :el_categories_3_path
  field :el_categories_4_path
  field :el_categories_5_path
  field :el_categories_6_path
  field :el_categories_7_path
  field :el_categories_8_path
  field :el_categories_9_path
  field :el_category
  field :el_comment_status
  field :el_creation_date
  field :el_file
  field :el_height
  field :el_id
  field :el_one_off_videographer
  field :el_photo_height
  field :el_photo_width
  field :el_sites_1_domain
  field :el_size
  field :el_status
  field :el_story_id
  field :el_thumbnail_photo
  field :el_title
  field :el_transcript_file
  field :el_transcript_text
  field :el_type_id
  field :el_type_mime_type
  field :el_type_name
  field :el_type_slug
  field :el_url
  field :el_videographer_first_name
  field :el_videographer_last_name
  field :el_videographer_records_audioclips
  field :el_width
  field :wp_categories, type: Array, default: []
  field :wp_site, type: String, default: "main"
  field :computed_bylines, type: Array, default: []

  def bylines
    out = []
    if el_videographer_first_name || el_videographer_last_name
      out << { :first_name => el_videographer_first_name.strip,
               :last_name => el_videographer_last_name.strip }
    end

    if el_one_off_videographer
      #sometimes this field separates authors with "and" and sometimes with ","
      names = el_one_off_videographer.split(/( and |,)/)
      names.reject! { |obj| obj.include?(" and ") || obj.include?(",") }

      names.map do |name|
        split_name = name.split(" ") #separate first and last name --> inexact

        first_name = split_name.shift #put the first index in first name
        last_name = split_name.join(" ") #assume the rest is a last name

        out << { :first_name => first_name.strip,
                 :last_name => last_name.strip }
      end
     end

    out.compact #prune any nils
  end
  
  def categories
    out = (1..@@MAX_NUM_CATEGORIES).inject([]) do |init,indx| 
      init <<  self.send( "el_categories_#{indx}_path" )
    end
    out.compact
  end


end
