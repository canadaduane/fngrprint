require "httparty"
require 'net/http'

#add split by last function to strings
class String
  def split_by_last(char=" ")
    pos = self.rindex(char)
    pos != nil ? [self[0...pos], self[pos+char.length..-1]] : [self]
  end
end

def myputs(var)
puts var
open('log.log', 'a') { |f|
  f.puts var
}
end


nonehere=0
linknumber=0
first=Integer(ARGV[0])
last=Integer(ARGV[1])
fail "First is < 1" if first < 1
fail "Last is > 680" if last > 680
myputs("Downloading #{first} to #{last}")
for page in first..last
	
	archivequery='http://archive.org/search.php?query=language%3A%28english%29%20AND%20date%3A%5B1500-01-01%20TO%201830-01-01%5D'
	response = HTTParty.get(archivequery+"&page="+page.to_s)
	mylinks = response.body.split("<a class=\"titleLink\" href=\"",2)[1].split("<a class=\"titleLink\" href=\"")
	#mylinks1 = removefirst[1]
	#mylinks = mylinks1.split("<a class=\"titleLink\" href=\"")
	linknumber=(page*50)-50
	for link in mylinks
	linknumber=linknumber+1
		myputs "Query Page: #"+page.to_s+": "+linknumber.to_s
		baselink = link.split("\"")[0]
		filebasename = linknumber.to_s + "." + File.basename(baselink)
		filename = filebasename + ".epub"
		booklink = "http://archive.org"+baselink
		myputs "Book Page: " + booklink
		response2 = HTTParty.get(booklink)
		if response2.body.index("\">EPUB</a>")
			# get Year
			if response2.body.index("key\">Year:</span>") 
				year = response2.body.split("key\">Year:</span>",2)[1].split("</a>",2)[0].split("<a href=\"",2)[1].split(">",2)[1]
			else
				year = "no_year"
			end 
			myputs "Year: " + year
			
			
			errorcount=0
			while errorcount < 10 
			  begin  # Error Handling
				# SHOW EPUB FILE DOWNLOAD LINK
				downloadgetvars = response2.body.split("\">EPUB</a>",2)[0].split_by_last("<a href=\"")[1]
				downloadlink = "http://archive.org" + downloadgetvars 
				myputs " - Download book in EPUB format: " + downloadlink + "\n"
				# Make folder if it doesn't already exist.
				Dir.mkdir(year) unless File.exists?(year)
				Dir.mkdir(File.join(year,filebasename)) unless File.exists?(File.join(year,filebasename))
				resp = HTTParty.get(downloadlink)
					#resp = http.get(downloadgetvars)
					fullname = File.join(File.join(year,filebasename),filename)
					myputs "Downloading as filename: " + fullname
					
					open( fullname, "wb") do |file|
						file.write(resp.body)
					end
					# Upload to cloud files
					myputs "Sending #{fullname} to cloud files"
					output = `upcs -c research #{fullname}`
					myputs "Done: #{output[0..100]}"
				#end download
				#
				#check filesize
				if File.size(fullname)>0
					myputs "Done downloading."
					errorcount=100
				else
					myputs "\n-- ******* WARNING *******  -- Filesize = 0 bytes. Trying again...\n"
					errorcount=errorcount+1
				end
			  rescue  # Error Handling
				 myputs "Could not download and save file. Trying again...";
				 errorcount=errorcount+1
			  else  # Error Handling
				 errorcount=100
			  end  # Error Handling
			end

			
		else	
			# EPUB LINK NOT FOUND!
			nonehere=nonehere+1
			myputs " --!-- NO EPUB FORMAT. "
				if response2.body.index("<h1>View the book</h1>")
				boxcontents=response2.body.split("<h1>View the book</h1>")[1].split("Help reading texts")[0].split("</a>")
					for content in boxcontents
						otherformat=content.split("<a href=")[1].split(">")[1]
						if otherformat
							myputs otherformat + " "
						end
					end
				else
					myputs " Page Read Error, OR no formats available on page? "
				end
			myputs " ("+nonehere.to_s+" Books unavailable in EPUB format so far)\n"
			
		end
		myputs "The above File was processed on " + Time.now.to_s
		#"<a href=\"/download/harryandlucycon05edgegoog/harryandlucycon05edgegoog.epub\">EPUB</a>
		
	end
end
