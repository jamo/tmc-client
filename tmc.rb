require_relative 'lib/client'

@c = Client.new

def select_course
  @c.ask_for_course_id
end

def list_exercises
  @c.list_exercises
end

def list_active
  @c.list_active
end

def download_all_available
  @c.download_all_available
end


download_all_available

#at startup

