Jekyll::Hooks.register :topics, :pre_render do |topic|
  # Generate information about the last modified date for each topic's page

  # get the current topic last modified time
  modification_time = File.mtime( topic.path )
  
  # inject modification_time in topic's data.
  topic.data['last-modified-date'] = modification_time
  
  end