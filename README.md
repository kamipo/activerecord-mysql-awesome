# ActiveRecord::Mysql::Awesome

[![Build Status](https://travis-ci.org/kamipo/activerecord-mysql-awesome.png?branch=master)](https://travis-ci.org/kamipo/activerecord-mysql-awesome)

Awesome patches backported for ActiveRecord MySQL adapters.

Contains numerous patches backported from Rails 5 for use in Rails 4.x applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-mysql-awesome'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-mysql-awesome

## Usage

Just install it.

Patches from the following Rails pull requests are included:

* [Add SchemaDumper support table_options for MySQL. #17569](https://github.com/rails/rails/pull/17569)
* [Add charset and collation options support for MySQL string and text columns. #17574](https://github.com/rails/rails/pull/17574)
* [Add bigint pk support for MySQL #17631](https://github.com/rails/rails/pull/17631)
* [If do not specify strict_mode explicitly, do not set sql_mode. #17654](https://github.com/rails/rails/pull/17654)
* [Add unsigned option support for MySQL numeric data types #17696](https://github.com/rails/rails/pull/17696)
* [Support for any type primary key #17851](https://github.com/rails/rails/pull/17851)

## Contributing

1. Fork it ( https://github.com/kamipo/activerecord-mysql-awesome/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
