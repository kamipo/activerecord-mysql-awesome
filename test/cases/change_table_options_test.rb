require 'cases/helper'
require 'support/schema_dumping_helper'

class ChangeTableOptionsTest < ActiveRecord::TestCase
  include SchemaDumpingHelper

  class Widget < ActiveRecord::Base
  end

  def setup
    @connection = ActiveRecord::Base.connection
    @connection.create_table(:widgets, force: true, options: "CHARSET latin1")
  end

  def teardown
    @connection.execute("DROP TABLE IF EXISTS widgets")
  end

  test "change table options" do
    @connection.change_table_options "widgets", "ENGINE=InnoDB DEFAULT CHARSET=utf8"
    schema = dump_table_schema "widgets"
    assert_match %r{create_table "widgets", force: :cascade, options: \"ENGINE=InnoDB DEFAULT CHARSET=utf8\"}, schema
  end
end
