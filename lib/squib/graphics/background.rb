module Squib
  class Card

    # :nodoc:
    # @api private
    def background(draw)
      use_cairo do |cc|
        cc.set_source_squibcolor(draw.color)
        cc.paint
      end
    end

  end
end
