require 'rubygems'
require 'json'
require 'faraday'
require 'yaml'
require 'pry'

config = YAML::load(File.open('config.yml'))
conn = Faraday.new(:url => 'http://tmc.mooc.fi/hy') do |faraday|
  faraday.request  :url_encoded             # form-encode POST params
  faraday.response :logger                  # log requests to STDOUT
  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
end
conn.basic_auth(config['username'],config['password'] )
response = conn.get 'courses.json', {api_version: 5}

@courses = JSON.parse resonse.body

binding.pry