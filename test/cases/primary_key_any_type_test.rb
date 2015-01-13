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
    @connection.execute("DROP TABLE IF EXISTS barcodes")
  end

  test "primary key with any type and options" do
    assert_equal "code", Barcode.primary_key

    column_type = Barcode.type_for_attribute(Barcode.primary_key)
    assert_equal :string, column_type.type
    assert_equal 42, column_type.limit
  end

  test "schema dump primary key includes type and options" do
    schema = dump_table_schema "barcodes"
    assert_match %r{create_table "barcodes", primary_key: "code", id: :string, limit: 42}, schema
  end
end
