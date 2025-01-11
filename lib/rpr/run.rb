module Rpr
  class Run
    RUBY_VERSION_REGEXP = /\Aruby (\d\.\d)/
    PLATFORM_REGEXP = /(aarch64|x86_64)/
    DATETIME_REGEXP = /(\d{4}-\d{2}-\d{2}-\d{6})/
    YJIT_FILE_FLAG = /with_yjit|ruby_yjit|yjit_rust/
    MJIT_FILE_FLAG = /with_mjit/
    DATETIME_FORMAT = "%Y-%m-%d-%H%M%S"

    JIT_TYPE_NOT_SET = Module.new

    attr_reader :file_path

    def initialize(file_path:)
      @file_path = file_path
      @platform = nil
      @ruby = nil
      @performed_at = nil
      @data = nil
      @jit_type = JIT_TYPE_NOT_SET
    end

    def platform
      @platform ||= PLATFORM_REGEXP.match(file_path).captures.first.to_sym
    end

    def ruby
      @ruby ||= begin
        version = RUBY_VERSION_REGEXP.match(data.dig(:ruby_metadata, :RUBY_DESCRIPTION)).captures.first
        jit_type ? "#{version} #{jit_type.to_s.upcase}" : version
      end
    end

    def performed_at
      @performed_at ||= DateTime.strptime(DATETIME_REGEXP.match(file_path).captures.first, DATETIME_FORMAT)
    end

    def benchmarks
      execution_time_benchmarks + memory_usage_benchmarks
    end

    private

    def data
      @data ||= JSON.load_file(file_path, symbolize_names: true)
    end

    def execution_time_benchmarks
      data[:times].map do |name, benchmark_data|
        Benchmark.new(name: name, data: benchmark_data, type: Benchmark::Types::EXECUTION_TIME)
      end
    end

    def memory_usage_benchmarks
      data[:peak_mem_bytes].map do |name, benchmark_data|
        Benchmark.new(name: name, data: benchmark_data, type: Benchmark::Types::MEMORY_USAGE)
      end
    end

    def jit_type
      return @jit_type if @jit_type != JIT_TYPE_NOT_SET

      @jit_type = case file_path
      when YJIT_FILE_FLAG then :yjit
      when MJIT_FILE_FLAG then :mjit
      end
    end
  end
end
