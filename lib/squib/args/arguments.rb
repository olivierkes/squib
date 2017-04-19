module Squib
  module Args
    class Arguments
      def initialize(hash, deck)
        @hash = hash
        @deck = deck
      end

      def only(*params)
        unless (@hash.keys - params).empty?
          raise "Unexpected parameter to Squib's #{caller_locations(1,1)[0].label}': '#{@hash.keys - params}'"
        end
        @params = params
      end

      def build(arg_class, method_defaults)
        args_array = Array.new(@deck.size) { arg_new(arg_class) }
        prep_layouts!
        expand_and_set_and_defaultify(arg_class, args_array)
        return args_array
      end

      private

      # Initialize the arg class and create all accessors
      # e.g. Args::Draw.new + define the attr_accessors
      def arg_new(arg_class)
        arg = arg_class.new(@deck)
        params = arg_class.parameters.keys
        arg_class.class_eval { attr_accessor *(params) }
        return arg
      end

      # Do singleton expansion on the layout argument as well
      # Treated differently since layout is not always specified
      def prep_layouts!
        layout_args = @hash[:layout]
        unless layout_args.respond_to?(:each)
          layout_args = [layout_args] * @deck.size
        end
        @hash[:layout] = layout_args || []
      end

      def expand_and_set_and_defaultify(arg_class, args)
        arg_class.parameters.keys.each do |p|
          @hash[p] = defaultify(arg_class, p)
          val = if expandable_singleton?(arg_class, p, @hash[p])
                  [@hash[p]] * @deck.size
                else
                  @hash[p] # not an expanding parameter
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
      def defaultify(arg_class, p)
        return @hash[p] if @hash.key? p          # (1) Use specified
        defaults = arg_class.parameters.merge(@dsl_method_defaults || {})
        defaults.merge! (@deck.defaults || {}) # user defaults override ours
        layout = @deck.layout
        @hash[:layout].map do |layout_arg|
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
      def expandable_singleton?(arg_class, p, opt)
        arg_class.expanding? && !opt.respond_to?(:each)
      end

    end
  end
end
