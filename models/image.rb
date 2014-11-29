class Image

	BASE_URL   = 'http://www.petharbor.com/get_image.asp'
	RESOLUTION = 'Detail'
	LOCATION   = 'ASTN'

	def initialize(path)
		@path = path
	end

	def self.from_pet_id(id)
		Image.new("?RES=#{RESOLUTION}&ID=#{id}&LOCATION=#{LOCATION}")
	end

	def url
		"#{BASE_URL}#{@path}"
	end
end