require 'rubygems'
require 'json'
require 'faraday'
require 'yaml'
require 'pry'

class Client
  attr_accessor :courses, :config
  def initialize
    @config = get_config
    response = get_connection(config[:username],config[:password])
    @courses = JSON.parse response.body
  end

  def get_config
    YAML::load(File.open('config.yml'))
  end

  def save_config
    File.open("config.yml", "w") {|f| f.write(config.to_yaml) }
  end

  def get_connection(username, password)
    conn = Faraday.new(:url => 'http://tmc.mooc.fi/hy') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
    conn.basic_auth(username, password) # )
    response = conn.get 'courses.json', {api_version: 5}
  end

  def list_courses
    @courses['courses'].each do |course|
      puts "#{course['id']} #{course['name']}"
    end
  end

  def get_my_course
    list = @courses['courses'].select {|course| course['id'] == config[:course_id]}
    list[0]
  end

  def list_exercises
    list = get_my_course['exercises'].map {|ex| ex['name']}
    print_exercises(list)
  end

  def print_exercises(hash)
    list = hash.each {|ex| puts ex['name']}
  end

  def list_active
    list = get_my_course['exercises'].select {|ex| ex['returnable'] == true and ex['completed']==false}
    print_exercises(list)
  end

  def run
    binding.pry
    puts "Welcome to TMC commandline utility"
    unless config[:course_id]
      puts "Select course"
      list_courses

      config[:course_id] = gets.chomp
      save_config
    end
    command = ""
    while command != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split
      command = parts[0]
      case command
        when 'q' then puts "Goodbye!"
        when 'list' then list_courses
        when 'my_course' then get_my_course
        when 'list_exercises' then list_exercises
        when 'list_active' then list_active
        else
          puts "Sorry, I don't know how to (#{command})"
      end
    end
  end

end

Client.new.run
