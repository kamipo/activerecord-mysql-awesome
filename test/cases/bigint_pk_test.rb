require 'cases/helper'

class PrimaryKeyBigIntTest < ActiveRecord::TestCase
  class Widget < ActiveRecord::Base
  end

  setup do
    @connection = ActiveRecord::Base.connection
    @connection.create_table(:widgets, id: :primary_key, limit: 8) { |t| }
  end

  teardown do
    @connection.drop_table :widgets
  end

  def test_bigint_primary_key
    assert_equal "id", Widget.primary_key

    column = Widget.columns_hash[Widget.primary_key]
    assert_equal :integer, column.type
    assert_equal 8, column.limit

    widget = Widget.create!
    assert_not_nil widget.id
  end
end
