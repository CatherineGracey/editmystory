require 'active_record'

options = {
  adapter: 'postgresql',
  database: 'stories',
  # username:
}

ActiveRecord::Base.establish_connection( ENV['DATABASE_URL'] || options)
# ApplicationRecord.establish_connection(options)
