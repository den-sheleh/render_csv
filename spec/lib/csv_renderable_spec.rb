# -*- encoding: utf-8 -*-
require './spec/spec_helper'

describe RenderCsv::CsvRenderable do
  before(:all) do
    Dog.create(name: "Sebastian O'Connor", age: 3, weight: 76.8)
    Dog.create(name: 'Ruby', age: 3, weight: 68.2)
    Dog.create(name: 'Shelby', age: 5, weight: 64.0)
    Cat.create(name: 'Kitty')
  end

  let(:csv_renderable_array) { array.extend RenderCsv::CsvRenderable }

  context 'object is an array' do

    context 'nil' do
      let(:array) { nil }

      it 'returns an empty string' do
        expect(csv_renderable_array.to_custom_csv).to eql("")
      end
    end

    context 'array is empty' do
      let(:array) { Array.new }

      it 'returns an empty string' do
        expect(csv_renderable_array.to_custom_csv).to eql("\n")
      end
    end

    context 'object is not an instance of AR class' do
      let(:array) { [1, 2, 3] }

      it 'returns a csv of the array' do
        expect(csv_renderable_array.to_custom_csv).to eql("1,2,3\n")
      end
    end
  end

  context 'object is an ActiveRecord object' do
    let(:array) { Dog.all }

    context 'options is blank' do
      it 'returns all columns' do
        expect(csv_renderable_array.to_custom_csv).to eql "Id,Name,Age,Weight\n1,Sebastian O'Connor,3,76.8\n2,Ruby,3,68.2\n3,Shelby,5,64.0\n"
      end
    end

    context 'options with :only param' do
      it 'returns only columns specified' do
        options = { only: [:name, :age] }

        expect(csv_renderable_array.to_custom_csv(options)).to eql "Name,Age\nSebastian O'Connor,3\nRuby,3\nShelby,5\n"
      end
    end

    context 'options with :exclude param' do
      it 'excludes columns specified' do
        options = { except: [:age] }

        expect(csv_renderable_array.to_custom_csv(options)).to eql "Id,Name,Weight\n1,Sebastian O'Connor,76.8\n2,Ruby,68.2\n3,Shelby,64.0\n"
      end
    end

    context 'options with :add_methods' do
      it 'includes specified method values' do
        options = { add_methods: [:human_age] }

        expect(csv_renderable_array.to_custom_csv(options)).to eql "Id,Name,Age,Weight,Human age\n1,Sebastian O'Connor,3,76.8,25\n2,Ruby,3,68.2,25\n3,Shelby,5,64.0,33\n"
      end
    end

    context 'options with :expect and :add_methods' do
      it 'includes method values with other options' do
        options = { except: [:id,:name], add_methods: [:human_age] }

        expect(csv_renderable_array.to_custom_csv(options)).to eql "Age,Weight,Human age\n3,76.8,25\n3,68.2,25\n5,64.0,33\n"
      end
    end

    context 'options with localized attribute names' do
      before { I18n.locale = :ru }
      after { I18n.locale = :en }

      it 'includes localized column names in header' do
        options = { except: [:id,:name], add_methods: [:human_age] }
        expect(csv_renderable_array.to_custom_csv(options)).to eql "Возраст,Вес,Человеческий возраст\n3,76.8,25\n3,68.2,25\n5,64.0,33\n"
      end
    end

    context 'options with :attributes' do
      it 'includes columns and methods in specific order' do
        options = { attributes: [:human_age, :id, :name] }
        expect(csv_renderable_array.to_custom_csv(options)).to eql "Human age,Id,Name\n25,1,Sebastian O'Connor\n25,2,Ruby\n33,3,Shelby\n"
      end
    end

    context 'options with :csv_options' do
      it 'includes columns and methods with configured separators' do
        options = { attributes: [:id, :name], csv_options: { col_sep: "\t", row_sep: "\r\n" } }
        expect(csv_renderable_array.to_custom_csv(options)).to eql "Id\tName\r\n1\tSebastian O'Connor\r\n2\tRuby\r\n3\tShelby\r\n"
      end
    end
  end

  context 'header and row columns defined by methods' do
    let(:array) { Cat.all }

    it 'includes specified method values' do
      expect(csv_renderable_array.to_custom_csv).to eql "ID,Cat's name\n1,Kitty\n"
    end
  end

  context 'object is an empty ActiveRelation' do
    let(:array) { Dog.where(age: 123) }

    it 'includes header' do
      expect(csv_renderable_array.to_custom_csv).to eql "Id,Name,Age,Weight\n"
    end
  end

  context 'object is array of ActiveRecords' do
    let(:array) { [Dog.first] }

    it 'includes header' do
      expect(csv_renderable_array.to_custom_csv).to eql "Id,Name,Age,Weight\n1,Sebastian O'Connor,3,76.8\n"
    end
  end

end
