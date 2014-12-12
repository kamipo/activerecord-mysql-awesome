require 'active_record/connection_adapters/abstract/schema_dumper'

module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module ColumnDumper
      def options_for_column_spec(table_name)
        { table_name: table_name }
      end

      def table_options(table_name)
        nil
      end
    end
  end
end
