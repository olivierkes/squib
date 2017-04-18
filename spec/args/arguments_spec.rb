require 'spec_helper'
require 'squib/args/arguments'

describe Squib::Args::Arguments do

  context '#only' do
    it 'allows some options' do
      args = Squib::Args::Arguments.new({a: 1, b: 2})
      expect(args.only(:a, :b)).to be_true
    end

    it 'allows some but not others' do
      args = Squib::Args::Arguments.new({a: 1, b: 2})
      expect(args.only(:a)).to be_true
    end
  end

end
