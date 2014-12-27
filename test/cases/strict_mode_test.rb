require 'cases/helper'
require 'support/connection_helper'

class StrictModeTest < ActiveRecord::TestCase
  include ConnectionHelper

  def setup
    super
    @connection = ActiveRecord::Base.connection
  end

  def test_mysql_strict_mode_enabled
    result = @connection.exec_query "SELECT @@SESSION.sql_mode"
    assert_equal [["STRICT_ALL_TABLES"]], result.rows
  end

  def test_mysql_strict_mode_specified_default
    run_without_connection do |orig_connection|
      ActiveRecord::Base.establish_connection(orig_connection.merge({strict: :default}))
      global_sql_mode = ActiveRecord::Base.connection.exec_query "SELECT @@GLOBAL.sql_mode"
      session_sql_mode = ActiveRecord::Base.connection.exec_query "SELECT @@SESSION.sql_mode"
      assert_equal global_sql_mode.rows, session_sql_mode.rows
    end
  end

  def test_mysql_strict_mode_disabled
    run_without_connection do |orig_connection|
      ActiveRecord::Base.establish_connection(orig_connection.merge({strict: false}))
      result = ActiveRecord::Base.connection.exec_query "SELECT @@SESSION.sql_mode"
      assert_equal [[""]], result.rows
    end
  end
end
