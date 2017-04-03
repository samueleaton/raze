class Raze::StaticFileIndexer
  INSTANCE = self.new

  property static_files = {} of String => String

  def index_files(directory)
    base_dir = Raze.config.static_dir
    Dir.foreach "#{base_dir}#{directory}" do |f|
      next if f == "." || f == ".."
      if File.directory? "#{base_dir}#{directory}/#{f}"
        # only index directory itself if "dir_listing" is enabled
        @static_files["#{directory}/#{f}"] = "dir" if Raze.config.static_config["dir_listing"]
        index_files("#{directory}/#{f}")
      else
        @static_files["#{directory}/#{f}"] = "file"
      end
    end
  end

  def indexed?(file)
    static_files[file]? || false
  end
end

module Raze
  def self.static_file_indexer
    Raze::StaticFileIndexer::INSTANCE
  end
end

Raze.static_file_indexer.index_files ""
puts "\nstatic_files: " + Raze.static_file_indexer.static_files.inspect.gsub(/,/, ",\n ").gsub(/\{/, "{\n  ")
