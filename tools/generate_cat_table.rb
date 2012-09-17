#This script generates a hash that maps the raw path from Ellington to a new wordpress category/tag AND site
#each Elington category maps to [ TAG/CATEGORY (TYPE), NAME, SITE ]
require File.expand_path('../config/environment.rb')
require 'set'

output_path =  TOOLS_ROOT_PATH + 'tables/categories.rb'

all_categories = Set.new #build a unique list of all of the ellington categories
i=0
Story.each do |s|
  s.categories.each { |cat| all_categories << cat }
  puts "Processed #{i} stories" if i % 1000 == 0
  i += 1
end

#write the categories down to a file as a hash that can be required into a ruby script
File.open(output_path, "w") do |f|
  f << "CATEGORY_TABLE = {\n"

  all_categories.each do |cat|
    down_cat = cat.downcase
    #apply some rough rules to make site decisions
    if down_cat.include?("cross campus")
      site = "cross-campus"
    elsif down_cat.include?("weekend")
      site = "weekend"
    elsif down_cat.include?("magazine")
      site = "magazine"
    else
      site = "main"
    end

    #strip patterns that are ubiquitous but not helpful
    wp_cat = String.new(cat) #frozen..?
    wp_cat.gsub! "/News/", ""
    wp_cat.gsub! "/Blogs/", ""
    wp_cat.gsub! "Cross Campus/", ""

    f << "\t"
    f << "\"#{cat}\" => [ \"tag\", \"#{wp_cat}\", \"#{site}\" ],\n"
  end

  f << '}'
end
