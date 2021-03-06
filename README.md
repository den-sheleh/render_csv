# render_csv

[![Build Status](https://travis-ci.org/beerlington/render_csv.png?branch=master)](https://travis-ci.org/beerlington/render_csv)
[![Gem Version](https://badge.fury.io/rb/render_csv.png)](http://badge.fury.io/rb/render_csv)
[![Code Climate](https://codeclimate.com/github/beerlington/render_csv.png)](https://codeclimate.com/github/beerlington/render_csv)
[![Dependency Status](https://gemnasium.com/beerlington/render_csv.png)](https://gemnasium.com/beerlington/render_csv)

Rails CSV renderer for ActiveRecord collections

## Rails & Ruby Versions Supported

*Rails:* 4.x

*Ruby:* 2.0.x and 2.1.x

## Installation

The gem is hosted at [rubygems.org](https://rubygems.org/gems/render_csv)

## What is it?

The CSV renderer allows you to render any collection as CSV data.

```ruby
class LocationsController < ApplicationController
  def index
    @locations = Location.all

    respond_to do |format|
      format.csv  { render csv: @locations }
    end
  end
end
```

Will render a CSV file similar to:

<table>
  <tr>
    <th>Name</th><th>Address</th><th>City</th><th>State</th><th>Zip</th><th>Created at</th><th>Updated at</th>
  </tr>
  <tr>
    <td>Pete's House</td><td>555 House Ln</td><td>Burlington</td><td>VT</td><td>05401</td><td>2011-07-26 03:12:44 UTC</td><td>2011-07-26 03:12:44 UTC</td>
  </tr>
  <tr>
    <td>Sebastians's House</td><td>123 Pup St</td><td>Burlington</td><td>VT</td><td>05401</td><td>2011-07-26 03:30:44 UTC</td><td>2011-07-26 03:30:44 UTC</td>
  </tr>
  <tr>
    <td>Someone Else</td><td>999 Herp Derp</td><td>Burlington</td><td>VT</td><td>05401</td><td>2011-07-26 03:30:44 UTC</td><td>2011-07-26 03:30:44 UTC</td>
  </tr>
</table>

## Usage Options

There are a few options you can use to customize which columns are included in the CSV file

### Exclude columns

```ruby
respond_to do |format|
  format.csv  { render csv: @locations, except: [:id] }
end
```

### Limit columns

```ruby
respond_to do |format|
  format.csv  { render csv: @locations, only: [:address, :zip] }
end
```

### Add methods as columns

```ruby
respond_to do |format|
  format.csv  { render csv: @locations, add_methods: [:method1, :method2] }
end
```

### Add methods as columns and exclude columns

```ruby
respond_to do |format|
  format.csv  { render csv: @locations, except: [:id], add_methods: [:method1, :method2] }
end
```

### Add attributes in specific order. This set will be overwrite all :only, :except, :add_methods options

```ruby
respond_to do |format|
  format.csv  { render csv: @locations, attributes: [:method2, :method1, :id] }
end
```

### Options for generated CSV

```ruby
respond_to do |format|
  format.csv  { render csv: @locations, csv_options: { col_sep: "\t", row_sep: "\r\n" } }
end
```

### Localize column's names

If you have translations for model's attributes under scope [:activerecord, :attributes, *model*] column names will be
automatically translated.

### Customize csv based on model methods

If you want to customize your csv file in more flexible way you can do it by defining methods 'csv_header'(class method), 'csv_row' on model.
'csv_header' should return array, which include names of columns.
'csv_row' return array of values for instance of model.

```ruby
class Cat < ActiveRecord::Base
  def self.csv_header
    ["ID", "Cat's name"]
  end

  def csv_row
    [id, name]
  end
end
```

## Copyright

Copyright © 2011-2014 Peter Brown. See LICENSE.txt for
further details.
