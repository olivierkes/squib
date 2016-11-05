module Squib
  class Deck
    def default(opts = {})
      opts.each do |param, value|
        defaults[param] = value
      end
    end

    def defaults
      @defaults ||= {}
    end
  end
end
