module Squib
  module Args
    class Arguments
      def initialize(hash)
        @hash = hash
      end

      def only(*params)
        unless (@hash.keys - params).empty?
          raise "Unexpected parameter to Squib's #{caller_locations(1,1)[0].label}': '#{@hash.keys - params}'"
        end
      end
    end
  end
end
