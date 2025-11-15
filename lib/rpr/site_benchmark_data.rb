module Rpr
  class SiteBenchmarkData
    RUBY_BENCHMARKS_CONFIG_PATH = "ruby-bench/benchmarks.yml"
    HEADLINE_CATEGORY = "headline"

    attr_reader :benchmarks

    def initialize
      @benchmarks = {}
    end

    def add_chart(serializer)
      benchmark = benchmarks[serializer.benchmark] ||= {name: serializer.benchmark.to_s, chart_groups: {}}
      chart_group = benchmark[:chart_groups][serializer.platform] ||= []

      chart_group << {id: serializer.id}
    end

    def to_h
      ruby_benchmark_names.filter_map do |name|
        next if benchmarks[name].nil?

        benchmark_data = benchmarks[name]
        {
          name: benchmark_data[:name],
          chart_groups: benchmark_data[:chart_groups].map do |platform, charts|
            {
              platform: platform,
              charts: charts
            }
          end
        }
      end.sort_by { |benchmark| benchmark[:headline] ? 0 : 1 }
    end

    private

    def ruby_benchmark_names
      YAML.load_file(RUBY_BENCHMARKS_CONFIG_PATH, symbolize_names: true).keys
    end
  end
end
