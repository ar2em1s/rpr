module Rpr
  module Services
    class ProcessBenchmarkData < Base
      FILES_PATH = "benchmark-data/raw_benchmark_data/**/*.json"
      IGNORE_FILE_REGEXP = /yjit_stats|yjit_rust_proto/
      BENCHMARKS_DATA_PATH = "data"
      SITE_DATA_PATH = "_data/benchmarks.json"

      attr_reader :site_data, :runs, :reports, :serializers

      def initialize
        @site_data = SiteBenchmarkData.new
      end

      def call
        load_data
        group_data_in_reports
        serialize_reports
        collect_site_data
        save_benchmark_data
        save_site_data
      end

      private

      def load_data
        @runs = Dir[FILES_PATH].filter_map do |path|
          Run.new(file_path: path) unless IGNORE_FILE_REGEXP.match?(path)
        end
      end

      def group_data_in_reports
        @reports = runs.each_with_object({}) do |run, reports|
          run.benchmarks.each do |benchmark|
            key = Rpr::Report.generate_id(benchmark.name, benchmark.type, run.platform)
            reports[key] ||= Rpr::Report.new(name: benchmark.name, type: benchmark.type, platform: run.platform)

            reports[key].add_statistics(run.ruby, timestamp: run.performed_at, result: benchmark.result)
          end
        end.values
      end

      def serialize_reports
        @serializers = reports.map { |report| Rpr::Serializer.new(report) }
      end

      def collect_site_data
        serializers.each { |serializer| site_data.add_chart(serializer) }
      end

      def save_benchmark_data
        serializers.each do |serializer|
          File.binwrite(File.join(BENCHMARKS_DATA_PATH, "#{serializer.id}.json"), JSON.pretty_generate(serializer.to_h))
        end
      end

      def save_site_data
        File.binwrite(SITE_DATA_PATH, JSON.pretty_generate(site_data.to_h))
      end
    end
  end
end
