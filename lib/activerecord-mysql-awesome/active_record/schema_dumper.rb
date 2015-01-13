require 'active_record/schema_dumper'

module ActiveRecord
  module Mysql
    module Awesome
      module SchemaDumper
        private

        def table(table, stream)
          @types = @types.merge(@connection.options_for_column_spec(table))
          pk = @connection.primary_key(table)
          pkcol = @connection.columns(table).detect { |c| c.name == pk }
          pkcolspec = @connection.column_spec_for_primary_key(pkcol, @types) if pkcol
          table_options = @connection.table_options(table)

          buf = StringIO.new
          super(table, buf)
          buf = buf.string
          buf.sub!(/(?=, force: (?:true|:cascade))/, pkcolspec.map {|key, value| ", #{key}: #{value}"}.join) if pkcolspec
          buf.sub!(/(?= do \|t\|)/, ", options: #{table_options.inspect}") if table_options
          stream.print buf
          stream
        ensure
          @types = @connection.native_database_types
        end
      end
    end
  end

  class SchemaDumper #:nodoc:
    prepend Mysql::Awesome::SchemaDumper
  end
end
