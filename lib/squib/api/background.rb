require_relative '../args/card_range'
require_relative '../args/draw'

module Squib
  class Deck

    # DSL method. See http://squib.readthedocs.io
    def background(opts = {})
      dsl_defaults = {} # nothing non-standard for this method
      range = Args::CardRange.new(opts[:range], deck_size: size)
      draws = Args::Builder.new.build(self, opts, Args::Draw2, dsl_defaults)
      # draw  = Args::Draw.new(custom_colors).load!(opts, expand_by: size, layout: layout, dpi: dpi)
      range.each { |i| @cards[i].background(draws[i]) }
    end

  end
end
