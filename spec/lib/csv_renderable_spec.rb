# -*- encoding: utf-8 -*-
require './spec/spec_helper'

describe RenderCsv::CsvRenderable do
  let(:csv_renderable_array) { array.extend RenderCsv::CsvRenderable }

  context 'object is an array' do

    context 'array is empty' do
      let(:array) { Array.new }

      it 'returns an empty string' do
        expect(csv_renderable_array.to_custom_csv).to eql('')
      end
    end

    context 'object is not an instance of AR class' do
      let(:array) { [1, 2, 3] }

      it 'returns a csv of the array' do
        expect(csv_renderable_array.to_custom_csv).to eql('1,2,3')
      end
    end
  end

  context 'object is an ActiveRecord object' do
    let(:sebastian) { Dog.create!(name: "Sebastian O'Connor", age: 3, weight: 76.8) }
    let(:ruby) { Dog.create!(name: 'Ruby', age: 3, weight: 68.2) }
    let(:shelby) { Dog.create!(name: 'Shelby', age: 5, weight: 64.0) }
    let(:array) { [sebastian, ruby, shelby] }

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

        expect(csv_renderable_array.to_custom_csv(options)).to eql "Id,Name,Weight\n7,Sebastian O'Connor,76.8\n8,Ruby,68.2\n9,Shelby,64.0\n"
      end
    end

    context 'options with :add_methods' do
      it 'includes specified method values' do
        options = { add_methods: [:human_age] }

        expect(csv_renderable_array.to_custom_csv(options)).to eql "Id,Name,Age,Weight,Human age\n10,Sebastian O'Connor,3,76.8,25\n11,Ruby,3,68.2,25\n12,Shelby,5,64.0,33\n"
      end
    end

    context 'options with :expect and :add_methods' do
      it 'includes method values with other options' do
        options = { except: [:id,:name], add_methods: [:human_age] }

        expect(csv_renderable_array.to_custom_csv(options)).to eql "Age,Weight,Human age\n3,76.8,25\n3,68.2,25\n5,64.0,33\n"
      end
    end

    context 'options with localized attribute names' do
      before do
        I18n.backend.load_translations('spec/files/ru.yml')
        I18n.locale = :ru
      end

      it 'includes localized column names in header' do
        options = { except: [:id,:name], add_methods: [:human_age] }
        expect(csv_renderable_array.to_custom_csv(options)).to eql "Возраст,Вес,Человеческий возраст\n3,76.8,25\n3,68.2,25\n5,64.0,33\n"
      end
    end
  end
end
