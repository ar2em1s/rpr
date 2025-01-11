module Rpr
  class Serializer
    DATETIME_FORMAT = "%Y-%m-%d"
    RUBY_VERSION_REGEXP = /\d.\d(?!.*YJIT)/i

    attr_reader :report

    def initialize(report)
      @report = report
      @dates = nil
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

    def dates
      @dates ||= report.rubies.each_value.map { |points| points.map(&:first) }.flatten.minmax
        .map { |date| date.strftime(DATETIME_FORMAT) }
    end

    def data
      report.rubies.transform_values do |points|
        points.map { |date, result| [date.strftime(DATETIME_FORMAT), (result / base_result).round(4)] }
      end
    end

    private

    def base_result
      @base_result ||= begin
        oldest_ruby_version = report.rubies.keys.select { |version| RUBY_VERSION_REGEXP.match?(version) }.min_by(&:to_f)
        report.rubies[oldest_ruby_version].min_by(&:first).last
      end
    end
  end
end
