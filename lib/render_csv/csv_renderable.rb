require 'csv'

module RenderCsv
  module CsvRenderable
    # Converts an array to CSV formatted string
    # Options include:
    # :only => [:col1, :col2] # Specify which columns to include
    # :except => [:col1, :col2] # Specify which columns to exclude
    # :add_methods => [:method1, :method2] # Include addtional methods that aren't columns
    # :attributes => [:col1, :method1, :col2, :col3] # Override set of attributes in specific order
    # :csv_options => { col_sep: '\t', row_sep: '\r\n' } # Optional set of CSV options

    def to_custom_csv(options = {})
      csv_options = default_csv_options.merge(options[:csv_options] || {})

      if is_active_record?
        if !(model.respond_to?(:csv_header) || model.respond_to?(:csv_row)) || model.class_variable_defined?(:@@dynamic_generated_csv_methods)
          define_csv_methods(options)
        end
      end

      CSV.generate(csv_options) do |csv|
        if is_active_record?
          csv << model.csv_header
          self.each do |obj|
            csv << obj.csv_row
          end
        else
          csv << self if respond_to?(:to_csv)
        end
      end
    end

    private

    def define_csv_methods(options)
      if options[:attributes]
        columns = options[:attributes]
      else
        columns = model.column_names
        columns &= options[:only].map(&:to_s) if options[:only]
        columns -= options[:except].map(&:to_s) if options[:except]
        columns += options[:add_methods].map(&:to_s) if options[:add_methods]
      end

      model.class_variable_set(:@@dynamic_generated_csv_methods, true)
      model.class_eval "class << self; def csv_header; [\"#{ columns.map { |column_name| model.human_attribute_name(column_name) }.join('", "') }\"]; end; end"
      model.class_eval "def csv_row; [#{ columns.join(', ') }]; end"
    end

    def is_active_record?
      is_a?(ActiveRecord::Relation) || (present? && first.is_a?(ActiveRecord::Base))
    end

    def model
      @model ||= is_a?(ActiveRecord::Relation) ? klass : first.class
    end

    def default_csv_options
      { encoding: 'utf-8' }
    end
  end
end
