require 'bundler'
Bundler.require
require 'optparse'

options = {}
OptionParser.new do |opts|
	opts.on('-e', '--env ENV', 'Environment') do |env|
		options[:env] = env
	end
end.parse!

client = SODA::Client.new domain: 'data.austintexas.gov'

results = client.get 'kz4x-q9k5'

def result_to_hash(result)
	{
		species: result.type.downcase, 
		name: '', 
		pet_id: result.animal_id, 
		gender: result.sex.match(/(M|m)ale/) ? 'male' : 'female', 
		fixed: !result.sex.match(/(I|i)ntact/), 
		breed: result.looks_like, 
		found_on: result.intake_date, 
		scraped_at: Time.now.to_s,
		shelter_name: 'Austin Animal Center', 
		color: result.color, 
		active: !!result.at_aac.match(/(Y|y)es/) 
	}
end

result_hashes = results.each_with_index.reduce({}) do |hashes, (result, index)| 
	hashes[index.to_s.to_sym] = result_to_hash(result)
	hashes
end

username, password = options[:env] == 'development' ? [ 'username', 'password' ] : [ ENV['http_username'], ENV['http_password'] ]

res = HTTP.auth(:basic, user: username, pass: password).post 'http://localhost:3000/populator/update', json: { pets: result_hashes }

puts res.body if res.code != 200

# EXAMPLE DATA RETURNED FROM AAC
# {
# 	"sex"=>"Neutered Male", 
# 	"looks_like"=>"Labrador Retriever Mix", 
# 	"color"=>"Tan/White", 
# 	"location"=>#<Hashie::Mash human_address="{\"address\":\"9316 MORIN DR\",\"city\":\"\",\"state\":\"\",\"zip\":\"78621\"}" latitude="30.286854711000444" longitude="-97.4511984399997" needs_recoding=false>, 
# 	"age"=>"2 years", 
# 	"intake_date"=>"2014-09-07T00:00:00", 
# 	"image"=>#<Hashie::Mash url="http://www.petharbor.com/pet.asp?uaid=ASTN.A687601">, 
# 	"at_aac"=>"Yes (come to the shelter)", 
# 	"type"=>"Dog", 
# 	"animal_id"=>"A687601"
# }