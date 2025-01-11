module Rpr
  class Benchmark
    module Types
      EXECUTION_TIME = :execution_time
      MEMORY_USAGE = :memory_usage
    end

    attr_reader :type, :data, :raw_name

    def initialize(name:, data:, type:)
      @raw_name = name
      @data = data
      @type = type
    end

    def result
      stats = Array(data).flatten
      stats.sum.to_f / stats.size
    end

    def name
      @name ||= raw_name.to_s.sub("-", "_").sub(".rb", "").to_sym
    end
  end
end
