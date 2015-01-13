require 'active_record/connection_adapters/abstract/schema_dumper'

module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module ColumnDumper
      def options_for_column_spec(table_name)
        { table_name: table_name }
      end

      def column_spec_for_primary_key(column, options)
        return if column.type == :integer
        spec = { id: column.type.inspect }
        spec.merge!(prepare_column_options(column, options).delete_if { |key, _| [:name, :type].include?(key) })
      end

      def table_options(table_name)
        nil
      end
    end
  end
end
