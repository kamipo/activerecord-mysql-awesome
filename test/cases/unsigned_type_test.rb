require 'cases/helper'
require 'support/schema_dumping_helper'

class UnsignedTypeTest < ActiveRecord::TestCase
  include SchemaDumpingHelper

  class UnsignedType < ActiveRecord::Base
  end

  setup do
    @connection = ActiveRecord::Base.connection
    @connection.create_table("unsigned_types", force: true) do |t|
      t.column :unsigned_integer, "int unsigned"
      t.integer :unsigned_integer, unsigned: true
      t.float   :unsigned_float,   unsigned: true
      t.decimal :unsigned_decimal, unsigned: true, precision: 10, scale: 2
    end
  end

  teardown do
    ActiveRecord::Base.connection.drop_table "unsigned_types"
  end

  def test_minus_value_is_out_of_range
    assert_raise(RangeError) do
      UnsignedType.create(unsigned_integer: -10)
    end
    assert_raise(ActiveRecord::StatementInvalid) do
      UnsignedType.create(unsigned_float: -10.0)
    end
    assert_raise(ActiveRecord::StatementInvalid) do
      UnsignedType.create(unsigned_decimal: -10.0)
    end
  end

  def test_schema_dump_includes_unsigned_option
    schema = dump_table_schema "unsigned_types"
    assert_match %r{t.integer\s+"unsigned_integer",\s+limit: 4,\s+unsigned: true$}, schema
    assert_match %r{t.float\s+"unsigned_float",\s+limit: 24,\s+unsigned: true$}, schema
    assert_match %r{t.decimal\s+"unsigned_decimal",\s+precision: 10,\s+scale: 2,\s+unsigned: true$}, schema
  end
end
