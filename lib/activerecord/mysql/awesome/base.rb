if ActiveRecord::VERSION::MAJOR == 4
  require 'activerecord-mysql-awesome/active_record/schema_dumper'
  require 'activerecord-mysql-awesome/active_record/connection_adapters/abstract/schema_dumper'
  require 'activerecord-mysql-awesome/active_record/connection_adapters/abstract_mysql_adapter'
  require 'activerecord-mysql-awesome/active_record/connection_adapters/mysql2_adapter'
else
  raise "activerecord-mysql-awesome supports activerecord ~> 4.x"
end
