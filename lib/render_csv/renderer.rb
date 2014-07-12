require 'render_csv/csv_renderable'
require 'action_controller/metal/renderers'

ActionController.add_renderer :csv do |csv, options|
  filename = options[:filename] || "#{ Rails.application.class.parent_name }-report-#{ Time.current }.csv"
  csv.extend RenderCsv::CsvRenderable
  data = csv.to_custom_csv(options)
  send_data data, type: Mime::CSV, disposition: "attachment; filename=#{filename}"
end
