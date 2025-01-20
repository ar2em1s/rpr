module Rpr
  class Report
    ANOMALY_COEFFICIENT = 1.30
    ANOMALY_MINIMUM_AMOUNT = 2

    attr_reader :name, :type, :platform, :statistics

    def self.generate_id(*args)
      args.map(&:to_s).join("/")
    end

    def initialize(name:, type:, platform:)
      @name = name
      @type = type
      @platform = platform
      @statistics = {}
      @anomalies = []
    end

    def add_statistics(ruby_version, timestamp:, result:)
      version_results = statistics[ruby_version] ||= {}
      date = timestamp.to_date
      version_results[date] = Array(version_results[date]) << result
    end

    def anomalies
      return [] if type == Benchmark::Types::MEMORY_USAGE

      coefficients_per_version = rubies.transform_values do |points_map|
        points = points_map.to_a
        skip = 0
        points.filter_map.with_index(2) do |(date, result), next_result_index|
          skip -= 1
          next if next_result_index >= points.size || skip.positive?

          next_point = points[next_result_index]
          next_result = next_point.last
          coefficient = (result <= next_result) ? (next_result / result) : -(result / next_result)
          next if coefficient.abs < ANOMALY_COEFFICIENT

          skip = 5
          [next_point.first, coefficient]
        end.to_h
      end

      coefficients_per_version.flat_map { |_, coefficients| coefficients.keys }.uniq.filter_map do |date|
        coefficients = coefficients_per_version.filter_map { |_, version_coefficients| version_coefficients[date] }
        next if coefficients.size < ANOMALY_MINIMUM_AMOUNT

        date if coefficients.all?(&:negative?) || coefficients.all?(&:positive?)
      end
    end

    def rubies
      @rubies ||= statistics.transform_values do |date_results|
        date_results.map { |date, results| [date, results.sum / results.size] }
      end
    end
  end
end
