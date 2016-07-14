require 'active_record/connection_adapters/mysql2_adapter'

module ActiveRecord
  module ConnectionAdapters
    class Mysql2Adapter < AbstractMysqlAdapter
      class Version
        include Comparable

        def initialize(version_string)
          @version = version_string.split('.').map(&:to_i)
        end

        def <=>(version_string)
          @version <=> version_string.split('.').map(&:to_i)
        end

        def [](index)
          @version[index]
        end
      end

      def version
        @version ||= Version.new(@connection.server_info[:version].match(/^\d+\.\d+\.\d+/)[0])
      end
    end
  end
end
