require "oauth2"

puts "What is your UID?"
UID = gets.chomp
puts "What is your SECRET?"
SECRET = gets.chomp

client = OAuth2::Client.new(UID, SECRET, site: "https://api.intra.42.fr")

begin
	token = client.client_credentials.get_token
rescue
	puts "Sorry, could't resolve any client with those credentials"
	exit
else
	puts "Generated the token 🔑, now fetching from 42API"
end

puts "How many elements do you want to see for each page?"
max_elements = gets.chomp.to_i || 5

def menu
	puts "\e[H\e[2J"
	puts "1: Fetch Cursus"
	puts "2: Fetch Projects"
	puts "0: exit"
	puts "-----------------"
	print "Choose an option: "
	gets.chomp.to_i || 0
end

while (true)
	case menu()
	when 1
		puts "You choose to fetch Cursus [Page <= 0 to escape]"
		page_number = 1
		while (page_number > 0)
			puts "Please input the page you want to see"
			page_number = gets.chomp.to_i
			begin
				response = token.get("/v2/cursus", params: {page: {number: page_number, size: max_elements}})
				puts "Reponse Status: #{response.status}"
			rescue
				puts "Sorry something went wrong with the API or params"
			else
				info = response.parsed.map{|cursus| [cursus["id"], cursus["name"]]}
				puts "\e[H\e[2J"
				puts " #  ID | NAME "
				puts "-------|------"
				info.each_with_index do |c, i|
					puts "[#{i + 1}] #{c.first} | #{c.last}"
				end
				puts " --> Page #{page_number}, [#{response.parsed.length} elements]"
			end
		end
	when 2
		puts "You choose to fetch Projects [Page <= 0 to escape]"
		puts "Please input the id of the cursus for which you want to see the projects"
		cursus_id = gets.chomp.to_i
		page_number = 1
		while (page_number > 0)
			puts "Please input the page you want to see"
			page_number = gets.chomp.to_i
			begin
                                response = token.get("/v2/cursus/#{cursus_id}/projects", params: {page: {number: page_number, size: max_elements}})
                                puts "Reponse Status: #{response.status}"
                        rescue
                                puts "Sorry something went wrong with the API or params"
                        else
                                info = response.parsed.map{|project| [project["id"], project["name"], project["slug"]]}
                                puts "\e[H\e[2J"
                                puts "Sample data..."
                                info.each_with_index do |p, i|
                                        puts "[#{i + 1}] #{p[0]} | #{p[1]} | #{p[2]}"
                                end
				puts "-" * 130
				file_name = "cursus_#{cursus_id}_projects_page#{page_number}.json"
				puts " --> Because this fetch is too big, it generated a file '#{file_name}' so you can use some tool to vizualise the data"
				out_file = File.new(file_name, "w")
				out_file.puts(response.parsed.to_json)
				out_file.close
				puts " --> ✅ [CREATED]  #{File.expand_path(out_file)}"
				puts " --> Page #{page_number}, [#{response.parsed.length} elements]"
                        end

		end
	when 0
		puts "Thanks for using this tool, pulgamacanica salutes you! Cheers ;)"
		break
	else
		puts "Sorry that's not a valid option"
	end
end

