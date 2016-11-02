class User < ActiveRecord::Base
  has_secure_password
  has_many :stories
  has_many :suggestions
end

# Test user:
# password: pudding
# email: me@example.com
