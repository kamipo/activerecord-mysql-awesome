require 'cases/helper'
require 'support/schema_dumping_helper'

class CharsetCollationTest < ActiveRecord::TestCase
  include SchemaDumpingHelper

  class CharsetCollation < ActiveRecord::Base
  end

  setup do
    @connection = ActiveRecord::Base.connection
    @connection.create_table("charset_collations", force: true) do |t|
      t.string "string_ascii_bin", charset: 'ascii', collation: 'ascii_bin'
      t.text "text_ucs2_unicode_ci", charset: 'ucs2', collation: 'ucs2_unicode_ci'
    end
  end

  teardown do
    @connection.drop_table "charset_collations"
  end

  def test_column
    string_column = CharsetCollation.columns_hash['string_ascii_bin']
    assert_equal 'ascii_bin', string_column.collation

    text_column = CharsetCollation.columns_hash['text_ucs2_unicode_ci']
    assert_equal 'ucs2_unicode_ci', text_column.collation
  end

  def test_add_column
    @connection.add_column 'charset_collations', 'title', :string, charset: 'utf8', collation: 'utf8_bin'

    column = CharsetCollation.columns_hash['title']
    assert_equal 'utf8_bin', column.collation
  end

  def test_change_column
    @connection.add_column 'charset_collations', 'description', :string, charset: 'utf8', collation: 'utf8_unicode_ci'
    @connection.change_column 'charset_collations', 'description', :text, charset: 'utf8', collation: 'utf8_general_ci'

    CharsetCollation.reset_column_information

    column = CharsetCollation.columns_hash['description']
    assert_equal :text, column.type
    assert_equal 'utf8_general_ci', column.collation
  end

  def test_schema_dump_column_collation
    schema = dump_table_schema "charset_collations"
    assert_match %r{t.string\s+"string_ascii_bin",\s+limit: 255,\s+collation: "ascii_bin"$}, schema
    assert_match %r{t.text\s+"text_ucs2_unicode_ci",\s+limit: 65535,\s+collation: "ucs2_unicode_ci"$}, schema
  end
end
