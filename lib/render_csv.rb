module RenderCsv
  class << self
    def register!
      require 'render_csv/renderer'
    end
  end
end

RenderCsv.register!
