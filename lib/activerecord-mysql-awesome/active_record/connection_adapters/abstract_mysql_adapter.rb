require 'active_record/connection_adapters/abstract_mysql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter < AbstractAdapter

      class ChangeColumnDefinition < Struct.new(:column, :name) #:nodoc:
      end

      class ColumnDefinition < ActiveRecord::ConnectionAdapters::ColumnDefinition
        attr_accessor :auto_increment, :unsigned, :charset, :collation
      end

      class TableDefinition < ActiveRecord::ConnectionAdapters::TableDefinition
        def initialize(types, name, temporary, options, as = nil)
          super(types, name, temporary, options)
          @as = as
        end

        def new_column_definition(name, type, options) # :nodoc:
          column = super
          column.auto_increment = options[:auto_increment]
          column.unsigned  = options[:unsigned]
          column.charset   = options[:charset]
          column.collation = options[:collation]
          column
        end

        private

        def create_column_definition(name, type)
          ColumnDefinition.new name, type
        end
      end

      class SchemaCreation < AbstractAdapter::SchemaCreation
        def visit_AddColumn(o)
          add_column_position!("ADD #{accept(o)}", column_options(o))
        end

        private

        def visit_ColumnDefinition(o)
          sql_type = type_to_sql(o.type.to_sym, o.limit, o.precision, o.scale, o.unsigned)
          column_sql = "#{quote_column_name(o.name)} #{sql_type}"
          add_column_options!(column_sql, column_options(o)) unless o.type == :primary_key
          column_sql
        end

        def visit_ChangeColumnDefinition(o)
          change_column_sql = "CHANGE #{quote_column_name(o.name)} #{accept(o.column)}"
          add_column_position!(change_column_sql, column_options(o.column))
        end

        def column_options(o)
          column_options = super
          column_options[:first] = o.first
          column_options[:after] = o.after
          column_options[:auto_increment] = o.auto_increment
          column_options[:primary_key] = o.primary_key
          column_options[:charset]   = o.charset
          column_options[:collation] = o.collation
          column_options
        end

        def add_column_options!(sql, options)
          if options[:charset]
            sql << " CHARACTER SET #{options[:charset]}"
          end
          if options[:collation]
            sql << " COLLATE #{options[:collation]}"
          end
          if options[:primary_key] == true
            sql << " PRIMARY KEY"
          end
          super
        end

        def add_column_position!(sql, options)
          if options[:first]
            sql << " FIRST"
          elsif options[:after]
            sql << " AFTER #{quote_column_name(options[:after])}"
          end
          sql
        end

        def type_to_sql(type, limit, precision, scale, unsigned = false)
          @conn.type_to_sql type.to_sym, limit, precision, scale, unsigned
        end

        def quote_value(value, column)
          column.sql_type ||= type_to_sql(column.type, column.limit, column.precision, column.scale, column.unsigned)
          super
        end
      end

      class Column < ConnectionAdapters::Column # :nodoc:
        def unsigned?
          sql_type =~ /unsigned/i
        end
      end

      def options_for_column_spec(table_name)
        if collation = select_one("SHOW TABLE STATUS LIKE '#{table_name}'")["Collation"]
          super.merge(collation: collation)
        else
          super
        end
      end

      def prepare_column_options(column, options) # :nodoc:
        spec = super
        spec[:unsigned] = 'true' if column.unsigned?
        if column.collation && column.collation != options[:collation]
          spec[:collation] = column.collation.inspect
        end
        spec
      end

      def migration_keys
        super + [:unsigned, :collation]
      end

      def table_options(table_name)
        create_table_info = select_one("SHOW CREATE TABLE #{quote_table_name(table_name)}")["Create Table"]

        # strip create_definitions and partition_options
        raw_table_options = create_table_info.sub(/\A.*\n\) /m, '').sub(/\n\/\*!.*\*\/\n\z/m, '').strip

        # strip AUTO_INCREMENT
        raw_table_options.sub(/(ENGINE=\w+)(?: AUTO_INCREMENT=\d+)/, '\1')
      end

      alias type_to_sql_without_awesome type_to_sql
      def type_to_sql(type, limit = nil, precision = nil, scale = nil, unsigned = false)
        case type.to_s
        when 'integer'
          case limit
          when nil, 4, 11; 'int'  # compatibility with MySQL default
          else
            type_to_sql_without_awesome(type, limit, precision, scale)
          end.tap do |sql_type|
            sql_type << ' unsigned' if unsigned
          end
        when 'float', 'decimal'
          type_to_sql_without_awesome(type, limit, precision, scale).tap do |sql_type|
            sql_type << ' unsigned' if unsigned
          end
        when 'primary_key'
          "#{type_to_sql(:integer, limit, precision, scale, unsigned)} auto_increment PRIMARY KEY"
        else
          type_to_sql_without_awesome(type, limit, precision, scale)
        end
      end

      def add_column_sql(table_name, column_name, type, options = {})
        td = create_table_definition(table_name)
        cd = td.new_column_definition(column_name, type, options)
        schema_creation.visit_AddColumn cd
      end

      def change_column_sql(table_name, column_name, type, options = {})
        column = column_for(table_name, column_name)

        unless options_include_default?(options)
          options[:default] = column.default
        end

        unless options.has_key?(:null)
          options[:null] = column.null
        end

        td = create_table_definition(table_name)
        cd = td.new_column_definition(column.name, type, options)
        schema_creation.accept ChangeColumnDefinition.new cd, column.name
      end

      def rename_column_sql(table_name, column_name, new_column_name)
        column  = column_for(table_name, column_name)
        options = {
          default: column.default,
          null: column.null,
          auto_increment: column.extra == "auto_increment"
        }

        current_type = select_one("SHOW COLUMNS FROM #{quote_table_name(table_name)} LIKE '#{column_name}'", 'SCHEMA')["Type"]
        td = create_table_definition(table_name)
        cd = td.new_column_definition(new_column_name, current_type, options)
        schema_creation.accept ChangeColumnDefinition.new cd, column.name
      end

      alias configure_connection_without_awesome configure_connection
      def configure_connection
        _config = @config
        if [':default', :default].include?(@config[:strict])
          @config = @config.deep_merge(variables: { sql_mode: :default })
        end
        configure_connection_without_awesome
      ensure
        @config = _config
      end

      def create_table_definition(name, temporary = false, options = nil, as = nil) # :nodoc:
        TableDefinition.new native_database_types, name, temporary, options, as
      end
    end
  end
end
