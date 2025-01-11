module Rpr
  module Services
    class Base
      def self.call(...)
        new(...).call
      end
    end
  end
end
