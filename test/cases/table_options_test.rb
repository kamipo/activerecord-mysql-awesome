require 'cases/helper'
require 'support/schema_dumping_helper'

class TableOptionsTest < ActiveRecord::TestCase
  include SchemaDumpingHelper

  teardown do
    ActiveRecord::Base.connection.drop_table "table_options"
  end

  def test_dump_table_options
    ActiveRecord::Base.connection.create_table(:table_options, force: true, options: "COMMENT 'london bridge is falling down'")
    output = dump_table_schema("table_options")
    assert_match %r/COMMENT='london bridge is falling down'/, output
  end
end
