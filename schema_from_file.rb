require_relative "config/environment.rb"
require "set"
require "json"

class SchemaFromFile
  def initialize(file_path, options = {})
    #takes a *full* path to a file
    @options = {}
    @options[:output_dir] = options[:output_dir] || File.expand_path('mongoid/')
    @options[:field_prefix] = options[:field_prefix] || 'el_'

    @input_file_path = file_path
    @output_name = File.basename(@input_file_path,'.json')
    ensure_dir(@options[:output_dir])

    @output_schema = Class.new(Schema)
    @output_schema.setcollection(@output_name)
    @fields_seen = Set.new()
  end

  def process!
    #opens the file and engages the parser
    File.open(@input_file_path) do |file|
      parse_lines(file)
    end
  end

  private

  def parse_lines(file)
    #loop through the file, parsing each line into JSON and passing to helper functions
    counter = 0
    file.each_line do |line|
      json = JSON.parse(line)
      create_fields(json.keys)
      insert_record(json)
      write_mongoid_model
      counter += 1
      if counter % 1000 == 0
        puts "processed #{counter} records"
      end
    end
  end

  def create_fields(fieldnames)
    #takes a list of field names and creates new ones in @ouput_schema if necessary
    fieldnames.each do |fn|
      prefixed_name = @options[:field_prefix] + fn
      unless @fields_seen.include? prefixed_name
        @output_schema.newfield(prefixed_name)
        @fields_seen << prefixed_name
      end
    end
  end

  def insert_record(record)
    #takes a json record and inserts it into the mongo database
    record_prefixed = {}
    record.each do |key,value|
      record_prefixed[ @options[:field_prefix] + key ] = value
    end
    rec = @output_schema.new(record_prefixed).save!
  end

  def ensure_dir(full_path) 
    #checks for a directory at full_path. if DNE, create or die
    unless File.directory?(full_path)
      Dir.mkdir(full_path)
    end
  end

  def write_mongoid_model
    #writes a ruby file that matches the schema that was found
    field_strs = @fields_seen.to_a.sort.map { |f| "field :#{f}" }.join("\n  ")
    output = <<STR
class #{ @output_name.capitalize }
  include Mongoid::Document
  store_in collection: :#{@output_name}
  #{ field_strs }
end
STR
    File.open( File.join(@options[:output_dir], @output_name + '.rb' ), "w" ) { |f| f << output }
  end

  class Schema
      #this is the metaclass ancestor
      include Mongoid::Document
      def self.newfield(name, options = {} )
        options[:type] ||= String 
        options[:default] || ''
        self.send(:field,name,options)
      end

      def self.setcollection(name)
        self.send(:store_in, collection: name)
      end
  end

end

#allow the class to be loaded into other files
#only dive in if the file name matches what's expected
if __FILE__ == "schema_from_file.rb"
  input_dir = File.expand_path(ARGV[0])
  Dir.foreach(input_dir) do |filename|
    split_filename = filename.split(".")
    if  split_filename.length == 2 && split_filename[1] == "json"
      puts "\n\nProcessing: #{filename} \n\n"
      SchemaFromFile.new(File.join(input_dir,filename)).process!
    end
  end
end
