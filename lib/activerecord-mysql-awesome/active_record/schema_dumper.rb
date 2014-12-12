require 'active_record/schema_dumper'

module ActiveRecord
  class SchemaDumper #:nodoc:
    private

    alias table_without_awesome table
    def table(table, stream)
      @types = @types.merge(@connection.options_for_column_spec(table))
      if table_options = @connection.table_options(table)
        buf = StringIO.new
        table_without_awesome(table, buf)
        stream.print buf.string.sub(/(?= do \|t\|)/, ", options: #{table_options.inspect}")
        stream
      else
        table_without_awesome(table, stream)
      end
    ensure
      @types = @connection.native_database_types
    end
  end
end
