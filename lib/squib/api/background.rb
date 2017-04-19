require_relative '../args/card_range'
require_relative '../args/draw'
require_relative '../args/draw2'
require_relative '../args/builder.rb'
require_relative '../args/arguments.rb'

module Squib
  class Deck

    # DSL method. See http://squib.readthedocs.io
    def background(opts = {})
      args = Arguments.new opts, self
      args.only :range, :color, :layout
      range = Args::CardRange.new(opts[:range], deck_size: size)
      draws = args.build Args::Draw2, {} # nothing non-standard for this method
      range.each { |i| @cards[i].background(draws[i]) }
    end

  end
end
