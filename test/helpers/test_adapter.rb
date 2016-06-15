class TestAdapter
  def initialize(status, content)
    @status = status
    @content = content
  end

  def get(url, opts)
    yield @status, @content
  end
end
