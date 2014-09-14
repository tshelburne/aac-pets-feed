### About

This is a partner to the Pet Alerts website, and acts as a simple data source, using the Austin, TX 
Socrata data portal from [Austin Animal Center](https://data.austintexas.gov/Government/Austin-Animal-Center-Stray-Map/kz4x-q9k5).

### Install

`git clone git@github.com:tshelburne/aac-pets-feed.git`
`bundle install --path=vendor`

### Usage

To post to localhost:3000

`ruby scrape.rb --env development`

To post to http://pet-alert.heroku.com/

`ruby scrape.rb` - note that this will require ENV variables `http_username` and `http_password` 
to be set, matching authentication on the Heroku server.