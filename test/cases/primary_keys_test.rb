require 'cases/helper'
require 'support/schema_dumping_helper'

class PrimaryKeyAnyTypeTest < ActiveRecord::TestCase
  include SchemaDumpingHelper

  class Barcode < ActiveRecord::Base
  end

  setup do
    @connection = ActiveRecord::Base.connection
    @connection.create_table(:barcodes, primary_key: "code", id: :string, limit: 42, force: true)
  end

  teardown do
    @connection.drop_table 'barcodes', if_exists: true
  end

  test "primary key with any type and options" do
    assert_equal "code", Barcode.primary_key

    column = Barcode.columns_hash[Barcode.primary_key]
    assert_equal :string, column.type
    assert_equal 42, column.limit
  end

  test "schema dump primary key includes type and options" do
    schema = dump_table_schema "barcodes"
    assert_match %r{create_table "barcodes", primary_key: "code", id: :string, limit: 42}, schema
  end
end

class PrimaryKeyBigSerialTest < ActiveRecord::TestCase
  include SchemaDumpingHelper

  class Widget < ActiveRecord::Base
  end

  setup do
    @connection = ActiveRecord::Base.connection
    @connection.create_table(:widgets, id: :bigint, unsigned: true, force: true)
  end

  teardown do
    @connection.drop_table 'widgets', if_exists: true
  end

  test "primary key column type with bigint" do
    column = @connection.columns(:widgets).find { |c| c.name == 'id' }
    assert column.auto_increment?
    assert_equal :integer, column.type
    assert_equal 8, column.limit
    assert column.unsigned?
  end

  test "primary key with bigserial are automatically numbered" do
    widget = Widget.create!
    assert_not_nil widget.id
  end

  test "schema dump primary key with bigint" do
    schema = dump_table_schema "widgets"
    assert_match %r{create_table "widgets", id: :bigint, unsigned: true}, schema
  end
end
