require 'bundler'
Bundler.require
require 'optparse'
require_relative 'models/image'

options = {}
OptionParser.new do |opts|
	opts.on('-e', '--env ENV', 'Environment') do |env|
		options[:env] = env
	end
end.parse!

client = SODA::Client.new domain: 'data.austintexas.gov'
results = client.get 'kz4x-q9k5'
puts "Retrieved #{results.count} results..."

def result_to_hash(result)
	{
		species: result.type.downcase, 
		name: '', 
		image: Image.from_pet_id(result.animal_id).url,
		pet_id: result.animal_id, 
		gender: result.sex.match(/(Fem|fem)ale/) ? 'female' : 'male', 
		fixed: !result.sex.match(/(I|i)ntact/), 
		breed: result.looks_like, 
		found_on: result.intake_date, 
		scraped_at: Time.now.to_s,
		shelter_name: 'Austin Animal Center', 
		color: result.color, 
		active: !!result.at_aac.match(/(Y|y)es/) 
	}
end

puts 'Formatting result data...'
result_hashes = results.each_with_index.reduce({}) do |hashes, (result, index)| 
	hashes[index.to_s.to_sym] = result_to_hash(result)
	hashes
end

puts 'Posting to Pet Alerts...'
domain, username, password = options[:env] == 'development' ? [ 'localhost:3000', 'username', 'password' ] : [ 'pet-alert.herokuapp.com', ENV['http_username'], ENV['http_password'] ]
res = HTTP.auth(:basic, user: username, pass: password).post "http://#{domain}/populator/update", json: { pets: result_hashes }

puts res.code != 200 ? res.body : 'Everything looks good...' 

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