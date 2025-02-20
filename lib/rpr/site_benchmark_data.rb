module Rpr
  class SiteBenchmarkData
    attr_reader :benchmarks

    def initialize
      @benchmarks = {}
    end

    def add_chart(serializer)
      benchmark = benchmarks[serializer.benchmark] ||= {name: serializer.benchmark.to_s, chart_groups: {}}
      chart_group = benchmark[:chart_groups][serializer.platform] ||= []

      chart_group << {
        title: serializer.title, type: serializer.benchmark_type, anomalies: serializer.anomalies, data: serializer.data
      }
    end

    def to_h
      benchmarks.sort_by(&:first).map do |name, benchmark_data|
        {
          name: name,
          chart_groups: benchmark_data[:chart_groups].map do |platform, charts|
            {
              platform: platform,
              charts: charts
            }
          end
        }
      end
    end
  end
end
