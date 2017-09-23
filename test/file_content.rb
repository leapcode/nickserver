module FileContent
  def file_content(filename)
    (@file_contents ||= {})[filename] ||= File.read(file_path(filename))
  end

  def file_path(filename)
    format('%s/files/%s', File.dirname(__FILE__), filename)
  end
end
