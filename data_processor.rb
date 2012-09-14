require File.expand_path(File.join( 'config','environment.rb') )
require 'set'

class DataProcessor
  include Singleton
  #this class handles ALL of the data cleaning processes
  #
  #It should be possible to run the DataProcessor on a raw Ellington dump and then be immediately
  #ready to run the PHP importer against the database.
  
  def process!
    build_complete_users_table
  end

  def print_header(val)
    puts "#{ '-' * 10 }  #{val}  #{ '-' * 10}\n" 
  end

  def print_record_count(i)
    puts "Imported #{i} records \n" if i % 1000 == 0
  end

  def build_complete_users_table
    #merges data from the Ellington users, stories, photos, and videos, collections to generate
    #a wp_users collection.
    #
    #the data types with generated usernames must all respond to "bylines" which will return an array of author
    #hashes with :first_name and :last_name specified
    
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
end

DataProcessor.instance.process!
