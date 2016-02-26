require 'rubygems'
require 'google-search'
require 'nokogiri'
require 'zip'
require	'open-uri'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
#Search for srt in Google and get first link of subscene
puts "Enter in seriesName s00e00 format"
input_string = gets.chomp
query = "#{input_string} subscene"
link = ""
puts "searching for #{query}"
Google::Search::Web.new do |search|
	search.query = query
	link = search.first.uri
end
#Download srt from subscene
path = "C:/Users/souvik_d/Downloads"
doc = Nokogiri::HTML(open(link))
subtitle_link = doc.at_css("#downloadButton")['href']
subtitle_uri = "http://www.subscene.com#{subtitle_link}"
system "start #{subtitle_uri}"
sleep 7
#Get name of zip file to extract
zip_files=[]
files = Dir.entries("#{path}")
files.each do |item|
	if item.include?("zip")
		zip_files << item
	end
end
#function to unzip file
def unzip_file (file, destination)
	Zip::File.open(file) { |zip_file|
		zip_file.each { |f|
			f_path=File.join(destination, f.name)
			FileUtils.mkdir_p(File.dirname(f_path))
			zip_file.extract(f, f_path) unless File.exist?(f_path)
		}
	}
end
#Extract zip file and delete zip
zip_files.each do |name|
	file_name = "#{path}/#{name}"
	unzip_file(file_name, path)
	File.delete(file_name) if File.exist?(file_name)
end
srt_file_path = Dir.glob("#{path}/*.srt")
folders = Dir.glob("#{path}/**/*").reject {|e| !File.directory?(e)}
input_string = input_string.split(" ")
target_folder = ''
#Get target folder to move srt
folders.each do |item|
	if item.include?("#{input_string[0].capitalize}")
		if item.include?("#{input_string[1].upcase}")
			target_folder = item
		end
	end
end
#Move srt
srt_file = File.basename "#{srt_file_path}", '.*'
FileUtils.mv "#{path}/#{srt_file}.srt", "#{target_folder}"
