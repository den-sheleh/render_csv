$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rails/all'
require 'rspec/rails'
require 'render_csv/csv_renderable'

if defined? I18n
  I18n.enforce_available_locales = false
  I18n.load_path << File.expand_path('../support/ru.yml', __FILE__)
end


# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Schema.define(version: 1) do
  create_table :dogs, force: true do |t|
    t.string :name
    t.integer :age
    t.float :weight
  end

  create_table :cats, force: true do |t|
    t.string :name
  end
end

RSpec.configure do |config|
end


class Dog < ActiveRecord::Base
  validates_presence_of :name, :age, :weight

  def human_age
    if age <= 2
      (age * 10.5).to_i
    else
      (2 * 10.5 + (age - 2) * 4).to_i
    end
  end
end

class Cat < ActiveRecord::Base
  validates_presence_of :name

  def self.csv_header
    ['ID', 'Cat\'s name']
  end

  def csv_row
    [id, name]
  end
end
