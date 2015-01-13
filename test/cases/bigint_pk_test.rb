require 'cases/helper'
require 'support/schema_dumping_helper'

class PrimaryKeyBigIntTest < ActiveRecord::TestCase
  include SchemaDumpingHelper

  class Widget < ActiveRecord::Base
  end

  setup do
    @connection = ActiveRecord::Base.connection
    @connection.create_table(:widgets, id: :bigint, force: true)
  end

  teardown do
    @connection.execute("DROP TABLE IF EXISTS widgets")
  end

  test "primary key column type with bigint" do
    column_type = Widget.type_for_attribute(Widget.primary_key)
    assert_equal :integer, column_type.type
    assert_equal 8, column_type.limit
  end

  test "primary key with bigint are automatically numbered" do
    widget = Widget.create!
    assert_not_nil widget.id
  end

  test "schema dump primary key with bigint" do
    schema = dump_table_schema "widgets"
    assert_match %r{create_table "widgets", id: :bigint}, schema
  end
end
