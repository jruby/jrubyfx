#!/usr/bin/env jruby
require 'jrubyfxml'

class LineChart < FXApplication

  def start(stage)
    months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", 
              "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    values = [[23, 14, 15, 24, 34, 36, 22, 45, 43, 17, 29, 25],
            [33, 34, 25, 44, 39, 16, 55, 54, 48, 27, 37, 29],
            [44, 35, 36, 33, 31, 26, 22, 25, 43, 44, 45, 44]]

    with(stage, title: "Line Chart Sample") do
      stage.layout_scene(800, 600) do 
        line_chart(category_axis, number_axis(label: :Month), title: :Stocks) do
          values.length.times do |j|
            xy_chart_series(name: "Portfolio #{j+1}") do
              months.length.times { |i| xy_chart_data(months[i], values[j][i]) }
            end
          end
        end
      end
      stage.show
    end
  end
end

LineChart.launch
