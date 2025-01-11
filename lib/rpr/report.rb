module Rpr
  class Report
    attr_reader :name, :type, :platform, :statistics

    def self.generate_id(*args)
      args.map(&:to_s).join("/")
    end

    def initialize(name:, type:, platform:)
      @name = name
      @type = type
      @platform = platform
      @statistics = {}
    end

    def add_statistics(ruby_version, timestamp:, result:)
      version_results = statistics[ruby_version] ||= {}
      date = timestamp.to_date
      version_results[date] = Array(version_results[date]) << result
    end

    def rubies
      @rubies ||= statistics.transform_values do |date_results|
        date_results.map { |date, results| [date, results.sum / results.size] }
      end
    end
  end
end
