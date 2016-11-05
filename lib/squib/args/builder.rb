module Squib
  module Args
    def build(arg_class, opts, deck, dsl_method_defaults = {})
      builder = Builder.new(arg_class, opts, deck, dsl_method_defaults)
      args = Array.new(deck.size) { builder.arg_new }
      builder.prep_layouts!
      builder.expand_and_set_and_defaultify(args)
      return args
    end
    module_function :build

    class Builder
      def initialize(arg_class, opts, deck, dsl_method_defaults)
        @arg_class = arg_class
        @opts = opts
        @deck = deck
        @dsl_method_defaults = dsl_method_defaults
      end

      # Initialize the arg class and create all accessors
      # e.g. Args::Draw.new + define the parameters
      def arg_new
        arg = @arg_class.new(@deck)
        params = @arg_class.parameters.keys
        @arg_class.class_eval { attr_accessor *(params) }
        return arg
      end

      # Do singleton expansion on the layout argument as well
      # Treated differently since layout is not always specified
      def prep_layouts!
        layout_args = @opts[:layout]
        unless layout_args.respond_to?(:each)
          layout_args = [layout_args] * @deck.size
        end
        @opts[:layout] = layout_args || []
      end

      def expand_and_set_and_defaultify(args)
        @arg_class.parameters.keys.each do |p|
          @opts[p] = defaultify(p)
          val = if expandable_singleton?(p, @opts[p])
                  [@opts[p]] * @deck.size
                else
                  @opts[p] # not an expanding parameter
                end
          args.each.with_index { |arg, i| arg.send("#{p}=", val[i]) }
        end
      end

      # Incorporate defaults and layouts
      #  (1) Use whatever is specified explicitly, otherwise...
      #  (2) Use layout when it's specified (non-nil for that card)
      #      (2a) Check for layout entry not existing when specified
      #  (3) Use "default" if
      #      (3a) No layout was specified, or
      #      (3b) Specified layout did not specify.
      #
      #  The "default" is specified in the Args::*.parameters. This can be
      #  overriden for a given dsl method via @dsl_method_defaults. (e.g stroke
      #  width is 0.0 for text, non-zero everywhere else). Furthermore, the   #  user can set their own defaults via the `default` DSL method - which #  overrides all other defaults.
      #
      def defaultify(p)
        return @opts[p] if @opts.key? p          # (1) Use specified
        defaults = @arg_class.parameters.merge(@dsl_method_defaults || {})
        defaults.merge! (@deck.defaults || {}) # user defaults override ours
        layout = @deck.layout
        @opts[:layout].map do |layout_arg|
          return defaults[p] if layout_arg.nil?  # (3a) no layout specified
          unless layout.key? layout_arg.to_s     # (2a) Oops! No such layout
            Squib.logger.warn("Layout \"#{layout_arg.to_s}\" does not exist in layout file - using default instead")
            return defaults[p]
          end
          if layout[layout_arg.to_s].key?(p.to_s)
            layout[layout_arg.to_s][p.to_s]     # (2)  Layout has param
          else
            defaults[p]                         # (3b) Layout lacks param
          end
        end
      end

      # Must be:
      #  (a) an expanding parameter, and
      #  (b) a singleton already (i.e. doesn't respond to :each)
      def expandable_singleton?(p, opt)
        @arg_class.expanding_parameters.include?(p) && !opt.respond_to?(:each)
      end

    end
  end
end
