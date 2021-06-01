#!/usr/bin/env jruby
require 'jrubyfx'

class LineChart < JRubyFX::Application

  def start(stage)
    months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", 
              "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    chart_data = [['RHT', [23, 14, 15, 24, 34, 36, 22, 45, 43, 47, 52, 54]],
                  ['SUNW', [33, 34, 25, 44, 39, 16, 55, 54, 48, 27, 37, 29]],
                  ['MFT', [44, 35, 36, 33, 31, 26, 22, 25, 43, 44, 45, 44]]]

    with(stage, title: "Line Chart Sample") do
      stage.layout_scene(800, 600) do 
        line_chart(category_axis,
                   number_axis(label: '$ (USD)'),
                   title: 'Stocks') do
          chart_data.each_with_index do |(name, chart), j|
            xy_chart_series(name: name) do
              months.each_with_index do |month, i|
                xy_chart_data(month, chart[i])
              end
            end
          end
        end
      end
      stage.show
    end
  end
end

LineChart.launch
