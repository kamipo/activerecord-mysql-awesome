module ConnectionHelper
  def run_without_connection
    original_connection = ActiveRecord::Base.remove_connection
    yield original_connection
  ensure
    ActiveRecord::Base.establish_connection(original_connection)
  end
end
