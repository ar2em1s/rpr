module Rpr
  class Serializer
    DATETIME_FORMAT = "%Y-%m-%d"
    RUBY_VERSION_REGEXP = /\d.\d(?!.*YJIT)/i

    attr_reader :report

    def initialize(report)
      @report = report
    end

    def benchmark
      report.name
    end

    def platform
      report.platform
    end

    def title
      report.type.to_s.sub("_", " ").capitalize
    end

    def benchmark_type
      report.type
    end

    def anomalies
      report.anomalies.map { |date| date.strftime(DATETIME_FORMAT) }
    end

    def data
      report.rubies.transform_values do |points|
        points.map { |date, result| [date.strftime(DATETIME_FORMAT), result] }
      end
    end
  end
end
