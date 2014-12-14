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

domain, username, password = options[:env] == 'development' ? [ 'localhost:3000', 'username', 'password' ] : [ 'pet-alert.herokuapp.com', ENV['http_username'], ENV['http_password'] ]

http = HTTP.auth(:basic, user: username, pass: password)
res = http.get "http://#{domain}/pets/without-images"

pets = JSON.parse res

puts "#{pets.count} results received..."

pets.each do |pet_hash|
	image = Image.from_pet_id pet_hash['remote_id']
	http.post "http://#{domain}/pet/#{pet_hash['id']}/reconcile-image", json: { image: image.url }
end

puts "Everything looks good..."