require File.expand_path(File.join( 'config','environment.rb') )
require File.expand_path(File.join( 'tables', 'categories.rb') )
require File.expand_path(File.join( 'tables', 'audioclips.rb') )
require 'set'
require 'nokogiri'

class DataProcessor
  include Singleton
  #this class handles ALL of the data cleaning processes
  #
  #It should be possible to run the DataProcessor on a raw Ellington dump and then be immediately
  #ready to run the PHP importer against the database.


  def process!
   # build_complete_users_table
     run_main_story_loop
  end

  def print_header(val)
    puts "#{ '-' * 10 }  #{val}  #{ '-' * 10}\n" 
  end

  def print_record_count(i)
    #puts "Imported #{i} records \n" if i % 1000 == 0
  end

  def build_complete_users_table
    #merges data from the Ellington users, stories, photos, and videos, collections to generate
    #a wp_users collection.
    #
    #the data types with generated usernames must all respond to "bylines" which will return an array of author
    #hashes with :first_name and :last_name specified
    #
    #this function loops through ALL the objects individually so that the set can be built up in memory once
    #and wont have to span multiple functions etc
    
    #first step is to build the real users in our wp_user collection
    print_header "Importing true users"
    i = 0
    User.each do |u|
      wp_u = WPUser.new
      wp_u.true_user = true
      wp_u.user_login = u.el_username
      wp_u.el_id = u.el_id
      wp_u.first_name = u.el_first_name
      wp_u.last_name = u.el_last_name
      wp_u.legacy_password = u.el_password
      wp_u.user_email = u.el_email

      wp_u.user_registered  = Time.parse(u.el_date_joined).strftime("%Y-%m-%d %H:%M:%S")

      wp_u.save!

      i += 1
      print_record_count i
    end

    #now for the harder part, build a bunch of "fake" users based on the bylines we have
    #we need to uniqueify out bylines first
    unique_bylines = Set.new 
    
    #we're going to do the same thing to Users, Videos, and Photos, so build one proc to be reused
    byline_grabber = Proc.new do |obj|
      obj.bylines.each { |byline| unique_bylines << byline }
    end

    print_header "Building unique author names"
    Video.each(&byline_grabber)
    Story.each(&byline_grabber)
    Photo.each(&byline_grabber)

    print_header "Importing those authors" 
    #now actually build these guys
    unique_bylines.each do |u| 
      wp_u = WPUser.new
      wp_u.true_user = false
      wp_u.first_name = u[:first_name]
      wp_u.last_name = u[:last_name]

      wp_u.save!
      i += 1
      print_record_count i
    end

  end

  def run_main_story_loop
    #a lot of things must happen on each story object and are relatively self contained (e.g.
    #the action on one story doesn't impact the action on any other story). So we do these in one
    #loop to cut down on the number of queries we run
    print_header "Running main story loop"

    i = 0 
    Story.each do |s|
#      load_wp_categories s
#      process_lead_photos s
      transform_inlines s
      
      s.save!
      i += 1
      print_record_count i
    end
  end

  def load_wp_categories(s)
    #uses the mapping defined in tables/categories.rb to populate the
    #story.wp_categories and story.wp_site fields. 
    #
    #s -- a story object
    s.wp_categories = [] #clear out anything there
    s.wp_site = "main" #default to main

    cat_list = Set.new #want to store tehse uniquely

    s.categories.each do |el_cat|
      wp_cats = CATEGORY_TABLE[el_cat] 
      next if wp_cats.nil?
      
      unless wp_cats.first.is_a? Array
        #if we don't get a nested array out, wrap the value in an array
        #when I built the table I neglected the complexities that would arise from having some w/ a nested
        #structure and others without. this fixes that
        wp_cats = [ wp_cats ]
      end
      
      wp_cats.each do |wp_cat|
        #since el_cats might resolve to multiple wp_cats, we need an inner loop
        cat_list << wp_cat #add categories one by one to the array
        s.wp_site = wp_cat.last unless wp_cat.empty?


        if wp_cat[1].downcase.gsub(" ","").include?("scene")
          cat_list << [ "tag", "Scene", "weekend" ]
        end
      end
    end

    s.wp_categories = cat_list.to_a.compact
  end

  def process_lead_photos(s)
    #we need to mark lead photos as used and set up which sites they should import to
    #Since multiple stories might use the same photo, they might need to be imported multiple times
    #
    #s -- a story object
    unless s.el_lead_photo_id.nil?
      lead_photo = Photo.where(el_id: s.el_lead_photo_id).first
      
      #mark that its used in this story's site
      lead_photo.wp_sites ||= []
      lead_photo.wp_sites << s.wp_site

      #mark that it's used in this story
      lead_photo.used_in ||= []
      lead_photo.used_in << s.el_id

      lead_photo.save!
    end
  end

  def transform_inlines(s)
    parsed = Nokogiri::HTML::DocumentFragment.parse s.el_story
    inlines =  parsed.css("inline")
    
    return if inlines.empty?

    inlines.each do |inline|
      renderer = InlineRenderer.new(inline, parsed)
      replacement = renderer.new_node
      inline.replace replacement unless replacement.nil?
      #puts parsed if inline["type"] == "video"
    end

    #s.el_story = parsed.to_html

  end

end

class InlineRenderer
  @@SUPPRESS_WARNINGS = false
  def initialize(cur_node, doc)
    @type = cur_node["type"] || ""
    @align = cur_node["align"] || ""
    @class = cur_node["class"] || ""
    @height = cur_node["height"] || ""
    @width = cur_node["width"] || ""
    @id = cur_node["id"] || ""
    @title = cur_node["title"] || ""

    @cur_node = cur_node
    @doc = doc
  end

  def new_node
    begin
      send("render_#{@type}")
    rescue NoMethodError
      puts "Warning: no renderer for #{@type} \n" unless @@SUPPRESS_WARNINGS
      nil
    end
  end

  private

  def render_oembed
    #worry about the youtube embeds. there's one that's a tinypic that I'm okay with losing
    if @cur_node.content.include? "youtube"
      #transform the URL into the typical youtube structure, just for safety

      generate_node_from_youtube_url @cur_node.content
    else
      #just remove the odd tinypic node
      puts "Warning: ignoring unrenderable oembed" unless @@SUPPRESS_WARNINGS
      nil
    end

  end

  def generate_node_from_youtube_url(url)
      id_regex = /v=(\w|-)*/
      id = id_regex.match(url)[0]

      if id.nil?
        alt_id_regex = /\/v\/(\w)*\?/
        id = al_id_regex.match(url)[0]
      end

      if id.nil?
        puts "Warning: unable to parse #{url}" unless @@SUPPRESS_WARNINGS
        return nil
      end

      output_node = Nokogiri::XML::Node.new "div", @doc
      output_node["class"] = "legacy oembed youtube inline"
      output_node.content = "\nhttp://youtube.com/watch?#{id}\n"
      output_node
  end

  def render_video
    if @id.nil?
      return nil
    end

    video = Video.where(el_id: @id).first
    if video.nil?
      puts "Warning: video record #{@id} not found" unless @@SUPPRESS_WARNINGS
      return nil
    end

    out = generate_node_from_youtube_url video.el_url
    out
  end

  def render_embedded
    if @id.nil?
      return nil
    end

    embed = Embedded.where(el_id: @id).first
    if embed.nil?
      puts "Warning: Embed #{@id} not found" unless @@SUPPRESS_WARNINGS
      return nil
    end

    embed_node = Nokogiri::HTML::DocumentFragment.parse embed.el_embedded_object 
    output_node = Nokogiri::XML::Node.new "div", @doc
    output_node["class"] = "legacy embedded #{embed.el_embedded_type_slug} inline".squeeze(" ")
    output_node << embed_node
  end

  def render_audioclip
    if @id.nil?
      return nil
    end

    if AUDIOCLIPS_TABLE[@id].nil?
      puts "Warning: Audioclip #{@id} not found" unless @@SUPPRESS_WARNINGS
      return nil
    end
    embed_node = Nokogiri::HTML::DocumentFragment.parse AUDIOCLIPS_TABLE[@id]

    output_node = Nokogiri::XML::Node.new "div", @doc
    output_node["class"] = "legacy embedded audioclip inline".squeeze(" ")
    output_node << embed_node
  end

  def render_text
    output_node = Nokogiri::XML::Node.new "div", @doc
    output_node["class"] = "legacy text inline".squeeze(" ")

    unless @title.empty?
      title_node = Nokogiri::XML::Node.new "h1", @doc
      title_node.content = @title
      output_node << title_node
    end

    @cur_node.children.each { |child| output_node << child.clone }

    output_node
  end
end

DataProcessor.instance.process!
