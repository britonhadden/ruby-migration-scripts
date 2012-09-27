#this tool builds a collection that contains all of the file paths in the media directory
#on the WPEngine server.  Necessary because we can't actually access the file during the WP
#import
require File.expand_path('../config/environment.rb')
require 'net/sftp'

puts "SSH user password: "
password = gets.chomp

Net::SFTP.start('yaledailynews.wpengine.com', 'yaledailynews', password: password ) do |sftp|
  base_path = '/wp-content/uploads/legacy/media/'
  dirs = ['']
  
  i = 0
  until dirs.empty?
    cur_dir = dirs.shift

    sftp.dir.foreach( File.join(base_path, cur_dir)) do |obj|
      next if obj.name == "." || obj.name == ".." #ignore special directories
      
      rel_path = File.join(cur_dir, obj.name)

      if obj.directory?
        dirs.push rel_path 
      else
        mediaent = MediaEnt.new
        rel_path[0] = '' if rel_path[0] == '/'
        mediaent.path = rel_path 
        mediaent.save!
      
        i+= 1
        puts "Imported #{i} records" if i % 1000 == 0
      end

    end
  end

end
