module ActiveRecord
  module Mysql
    module Awesome
      class Railtie < Rails::Railtie
        initializer 'activerecord-mysql-awesome' do
          ActiveSupport.on_load :active_record do
            require 'activerecord/mysql/awesome/base'
          end
        end
      end
    end
  end
end
