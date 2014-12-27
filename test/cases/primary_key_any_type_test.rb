require 'cases/helper'

class PrimaryKeyAnyTypeTest < ActiveRecord::TestCase
  class Barcode < ActiveRecord::Base
  end

  setup do
    @connection = ActiveRecord::Base.connection
    @connection.create_table(:barcodes, primary_key: "code", id: :string, limit: 42, null: false) { |t| }
  end

  teardown do
    @connection.drop_table :barcodes
  end

  def test_any_type_primary_key
    assert_equal "code", Barcode.primary_key

    column = Barcode.columns_hash[Barcode.primary_key]

    assert_equal :string, column.type
    assert_equal 42, column.limit
    assert_equal false, column.null
  end
end
